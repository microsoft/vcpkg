vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO highfive-devs/highfive
    REF "v.${VERSION}"
    SHA512 02203a416f250f498d734578eeec0b94f418ab27a4dd9b794420b8b98df8cb50606264ba64961c3ab38f5fb74fad9d4813e09e61c0f7629d15d683c891a3af49
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        boost       HIGHFIVE_TEST_BOOST
        opencv      HIGHFIVE_TEST_OPENCV
        xtensor     HIGHFIVE_TEST_XTENSOR
        eigen3      HIGHFIVE_TEST_EIGEN
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
        -DHIGHFIVE_UNIT_TESTS=OFF
        -DHIGHFIVE_EXAMPLES=OFF
        -DHIGHFIVE_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/HighFive)
if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/share/HighFive/HighFiveConfig.cmake")
    # left over with mixed case
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/HighFive")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
