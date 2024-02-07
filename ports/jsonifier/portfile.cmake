vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"    
    SHA512 a6907f01e76af23dde6a22758ff48eea647b24a1b0f39205fdc8d2808c66e691f8e2e682f0296dbab2d3a4b8d7a4ae18a011b4fa411d210108a3b88495e336be
    HEAD_REF main
    PATCHES
        uninstall-head.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
