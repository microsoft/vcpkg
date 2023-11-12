vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ada-url/ada
    REF "v${VERSION}"
    SHA512 b5617c1678d60024f38781c11b1098a164b2c752b985a0b4e70e082e4921781aa624e74fe166df6815fa040b3c7d4b0a551c9af00fdf932cdcbbeeb2cf4c65a2
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools ADA_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DADA_BENCHMARKS=OFF
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ada CONFIG_PATH "lib/cmake/ada")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES adaparse AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE" "${SOURCE_PATH}/LICENSE-MIT")
