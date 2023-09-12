# Must be removed on next release
vcpkg_download_distfile(CATCH2_PATCH
    URLS https://github.com/BlueBrain/HighFive/commit/be9285ee4661ff4154830989899a2a050d6fbc64.patch?full_index=1
    FILENAME ${PORT}-669-be9285ee.diff
    SHA512 d4b085557fdcfaed195efaa25e02358714e6ccb00cc532594592183e934d99e3b80883991fcac1d073fbedb5773d76a5e9a58da4328b71215dd30b259df1eba3
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BlueBrain/HighFive
    REF v2.6.2
    SHA512 80deb3d7f0b2e8e8c660ee37b189d1a4993e23b5ada30c72f3ef4fef80020f8564c8a5a507a34f891cec6c5db0d75d7c7de89040defaf91a3b1cec2018d1bf9e
    HEAD_REF master
    PATCHES
        fix-error-C1128.patch
        ${CATCH2_PATCH}
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
