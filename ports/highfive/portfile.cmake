vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueBrain/HighFive
    REF v2.3
    SHA512 5bf8bc6d3a57be39a4fd15f28f8c839706e2c8d6e2270f45ea39c28a2ac1e3c7f31ed2f48390a45a868c714c85f03f960a0bc8fad945c80b41f495e6f4aca36a
    HEAD_REF master
    PATCHES 
        fix-dependency-hdf5.patch
        fix-error-C1128.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        boost   HIGHFIVE_USE_BOOST
        tests   HIGHFIVE_UNIT_TESTS
        xtensor HIGHFIVE_USE_XTENSOR
        eigen3  HIGHFIVE_USE_EIGEN
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DHIGHFIVE_EXAMPLES=OFF
        -DHIGHFIVE_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

if("tests" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES 
            tests_high_five_base
            tests_high_five_easy
            tests_high_five_multi_dims
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/tests/unit" # Tools are not installed so release version tools are manually copied
    )
endif()

# Use PACKAGE_NAME to avoid folder HighFive and highfive are exist at same time
vcpkg_cmake_config_fixup(PACKAGE_NAME HighFive CONFIG_PATH share/HighFive/CMake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
