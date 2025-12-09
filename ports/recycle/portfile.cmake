vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steinwurf/recycle
    REF "${VERSION}"
    SHA512 c30cd3d388eeeea6a3db344e0e448878686c4a7bc106260c7de9d1eeb3477435eb1783bca09151356ba51200ecf14182891f97a38943959032c54b17ea0abac3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.rst")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
