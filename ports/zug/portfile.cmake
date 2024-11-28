vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/zug
    REF 7c22cc138e2a9a61620986d1a7e1e9730123f22b
    SHA512 ecf88ca56ae70ca87391ed34d6d6561e7da9810bba71e6abce2cd150b07cbb7180a7b90db96d0dc5f761fdeb43d75f5f0b47cbf45d78694c3177155d2005fe89
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        docs  zug_BUILD_DOCS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dzug_BUILD_EXAMPLES=OFF
        -Dzug_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
)


vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Zug)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
