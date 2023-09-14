vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/status-value-lite
    REF v1.1.0
    SHA512  09cad9f40f2b1592316b374e0d1a206e3a79a1c560a2ae3be3bdae9045fa026435cc29f1eee08e26e29a5499f8dc60e485adc50517a827977678d3a5a6e220d2
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
    test BUILD_TESTS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
       -DNSSV_OPT_BUILD_TESTS=${BUILD_TESTS}
       -DNSSV_OPT_BUILD_EXAMPLES=OFF  
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/status_value-lite)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
