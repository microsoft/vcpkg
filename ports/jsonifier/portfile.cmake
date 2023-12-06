vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"    
    SHA512 436dc66699ef924ca953e4d05b035ff7279fbbae932e74902eed0c6b9fd3e2bf282425c82f0d7d65392307602b5c603cf956d513df4c080c76566d4d9c61b373
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
