vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/type-lite
    REF v0.1.0
    SHA512  5a5ea623890af9c88c7f82869278af743e08b3dbda3c48c4523737244a7da76d2509501b4502efc2226aaef5df72b6ff69cd6b5b36c8cfc282b8c8406525016b
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test TYPE_LITE_OPT_BUILD_TESTS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTYPE_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
