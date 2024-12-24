vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/benchmark
    REF "v${VERSION}"
    SHA512 0e91e0e5a2222d7650fd8bd9cafb2f0e7c1689cd1b87b2cc529c738db12bfef31162aa5a4da78f7b0aa7f0101dc08b626802c58d39862458f82f9fea9316ca25
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBENCHMARK_ENABLE_TESTING=OFF
        -DBENCHMARK_INSTALL_DOCS=OFF
        -Werror=old-style-cast
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/benchmark)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
