vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arximboldi/zug
    REF dd80433152c9fa5b16a710c8b530fb6131749132
    SHA512 ed67a9d9bd6d8f9233e29ab3d13860adbc6a90d816be2ae50090b6b4543d9a936ec9883a1c5fc8a75cc34e819f06fd6e5cc45c7fdb755ee6976fbc19aef61a8f
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
