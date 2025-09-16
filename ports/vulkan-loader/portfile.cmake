set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Loader
    REF "vulkan-sdk-${VERSION}"
    SHA512 f77d42639037b79eeeba4007eded039527a345cd39ed1b6a3c5e786a418c481811a72c43cb24821268c7bc57c39941cfe5511e86362ac892c51d45a062dc0e2c
    HEAD_REF main
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
