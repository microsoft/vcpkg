vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qgis/o2
    REF "v${VERSION}"
    SHA512 3238ec24d5594d47db1885c15643853f7ed9c6fcb44be241833a01a1569ae89405f9daa37e46a3e02c230c54d3066d70bacf160a7f98c99e78eb68b2653f40e3
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Do2_WITH_KEYCHAIN=OFF
)
vcpkg_cmake_install()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
