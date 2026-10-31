set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Loader
    REF "vulkan-sdk-${VERSION}"
    SHA512 dc1884b0af24b94c974aa4526e3534625a187effe21088adfebeda94179ebe5ee789e7839765f20a1b1a460aa05a64bf1247310dc5649e61ba90dcb8647915b9
    HEAD_REF main
    PATCHES
        link-directfb.patch
        fix-marmasm-conditional-assembly.patch
)

vcpkg_find_acquire_program(PYTHON3)
# Needed to make port install vulkan.pc
vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xcb       BUILD_WSI_XCB_SUPPORT
        xlib      BUILD_WSI_XLIB_SUPPORT
        wayland   BUILD_WSI_WAYLAND_SUPPORT
        directfb  BUILD_WSI_DIRECTFB_SUPPORT
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TESTS:BOOL=OFF
    -DPython3_EXECUTABLE=${PYTHON3}
    ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/VulkanLoader" PACKAGE_NAME VulkanLoader)

set(copyright_files "${SOURCE_PATH}/LICENSE.txt")
foreach(source IN ITEMS cJSON.h loader_json.c)
    file(READ "${SOURCE_PATH}/loader/${source}" copyright)
    string(REGEX MATCH "^/[*]([^*]*)[*]/" copyright "${copyright}")
    file(WRITE "${CURRENT_BUILDTREES_DIR}/${source}" "${CMAKE_MATCH_1}")
    list(APPEND copyright_files "${CURRENT_BUILDTREES_DIR}/${source}")
endforeach()
if(VCPKG_TARGET_IS_WINDOWS)
    file(READ "${SOURCE_PATH}/loader/dirent_on_windows.c" copyright)
    string(REGEX MATCH "Copyright Kevlin[^*]*" copyright "${copyright}")
    file(WRITE "${CURRENT_BUILDTREES_DIR}/dirent_on_windows.c" "${copyright}")
    list(APPEND copyright_files "${CURRENT_BUILDTREES_DIR}/dirent_on_windows.c")
endif()
vcpkg_install_copyright(FILE_LIST ${copyright_files})

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
