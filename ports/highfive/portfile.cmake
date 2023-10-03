
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueBrain/HighFive
    REF "v${VERSION}"
    SHA512 4fbbd3898791a67e44329a5d0e20e16454b9393510236563b12fe4346cd4f2785d43d915ea05239ac1568d00651e41d85d93590f01454ffc1b82e7bba28e780a
    HEAD_REF master
    PATCHES
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

set(add_bin "")
if("tests" IN_LIST FEATURES)
    set(add_bin ADD_BIN_TO_PATH) # Seems to run tests as part of the build?
endif()

vcpkg_cmake_install(${add_bin})

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
