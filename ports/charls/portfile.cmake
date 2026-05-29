vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO team-charls/charls
    REF "${VERSION}"
    SHA512 b266b3f56f099419e75b301607db36475ffd4a76142431c74f94c60d2d2f1b1f278625dfd141bf986dcc60d5be4ec86f0ddc7cadd2eafaa7db201f9c0796bfda
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCHARLS_BUILD_TESTS=OFF
        -DCHARLS_BUILD_SAMPLES=OFF
        -DCHARLS_BUILD_FUZZ_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/charls)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
