set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Loader
    REF "vulkan-sdk-${VERSION}"
    SHA512 3376ce1be08ec4f453d6674118cc5e59d07ba7c7ec135f3cdd4d6820fa26bf4ef5e176ac9ade4413d25d90b4828060a1d0e0c1c2a7b4bec3118d70cdd61e6bfa
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
