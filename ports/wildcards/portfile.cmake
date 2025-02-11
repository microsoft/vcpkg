vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zemasoft/wildcards
    REF "v${VERSION}"
    SHA512 a739eaf567ec3e8a42c99dc694225e434e72e6ed83ab57d3a05fa3a710bfae7d15a6e7fcbf22f29f6d70a74941db73d976650cfc77b69441c6baa36f6727eb1f
    HEAD_REF main
    PATCHES
        install.patch
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWILDCARDS_BUILD_TESTS=OFF
        -DWILDCARDS_BUILD_EXAMPLES=OFF
        -DWILDCARDS_ENABLE_WERROR=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-wildcards)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
