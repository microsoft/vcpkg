vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueBrain/HighFive
    REF "v${VERSION}"
    SHA512 568fb58956ce8d218fd33a6fe5b519436ce296cdcf87b5620eb2af224b9e39f8f99008f3baff9a7024bbdb4052e5c47bb514091d2afd652abd28949e9096b6f1
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

if(HDF5_WITH_PARALLEL)
    message(STATUS "${HDF5_WITH_PARALLEL} Enabling HIGHFIVE_PARALLEL_HDF5.")
    list(APPEND FEATURE_OPTIONS "-DHIGHFIVE_PARALLEL_HDF5=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DHIGHFIVE_EXAMPLES=OFF
        -DHIGHFIVE_BUILD_DOCS=OFF
        -DCMAKE_CATCH_DISCOVER_TESTS_DISCOVERY_MODE=PRE_TEST
    MAYBE_UNUSED_VARIABLES
        CMAKE_CATCH_DISCOVER_TESTS_DISCOVERY_MODE
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

vcpkg_cmake_config_fixup(CONFIG_PATH share/HighFive/CMake)
if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/share/HighFive/HighFiveConfig.cmake")
    # left over with mixed case
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/HighFive")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
