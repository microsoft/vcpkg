vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/pugixml
    REF "v${VERSION}"
    SHA512 730d203829eb24d6e1c873f9b921ae97cf7a157fd45504151bc2e61adea5c536eaf33ff38c5ad61629b54a6686135ff1834a61102b4660fbb9ead4ecf20dfd34
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPUGIXML_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
