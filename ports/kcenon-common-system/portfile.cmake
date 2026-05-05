set(VCPKG_BUILD_TYPE release) # header only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kcenon/common_system
    REF "v${VERSION}"
    SHA512 ac458878395dbac632aa56a188f49d0c996e9334b67914d1e9a095d8f2bf45ea988232e31259758b595deb3374f833edfd91948a71a042f401a3db222600758c
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        yaml BUILD_WITH_YAML_CPP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOMMON_BUILD_TESTS=OFF
        -DCOMMON_BUILD_INTEGRATION_TESTS=OFF
        -DCOMMON_BUILD_EXAMPLES=OFF
        -DCOMMON_BUILD_BENCHMARKS=OFF
        -DCOMMON_BUILD_DOCS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME common_system
    CONFIG_PATH lib/cmake/common_system
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib") # empty directory

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
