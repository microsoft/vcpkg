vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ada-url/ada
    REF "v${VERSION}"
    SHA512 a27fc3f8713e73baacbec4f36688bb60c71cdde0ad6142dfe314d09385757833e6166995a955856620183f6fe9bf04d7e4d62e3f3de11c6af86d2d988b719729
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DADA_BENCHMARKS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ada CONFIG_PATH "lib/cmake/ada")

vcpkg_copy_tools(TOOL_NAMES adaparse AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE" "${SOURCE_PATH}/LICENSE-MIT")
