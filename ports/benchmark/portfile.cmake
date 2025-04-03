vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/benchmark
    REF "v${VERSION}"
    SHA512 64e964f02c118935305ca3e7d3f732f2e093f927371bd1729467f6cb75dc0c42492f9f02c3191e3d8affdc9bab2e66becf10bd4250b768854074bf69efa7e4f2
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
