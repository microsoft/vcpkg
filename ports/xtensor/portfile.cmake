# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor
    REF 9733efcfd4bd76115c822a03dd79fbea3bda6589 # 0.21.6
    SHA512 966b397b5b77acdf79215f455007f7fa08376dab3fa3641e69d2f0f23e9bbedcff245e96ba5cd010ce51dee8b8c03fc0fe5dd1fa552f99b5cbedeaea400ab0c1
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    xsimd XTENSOR_USE_XSIMD
    tbb XTENSOR_USE_TBB
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DXTENSOR_ENABLE_ASSERT=OFF
        -DXTENSOR_CHECK_DIMENSION=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARK=OFF
        -DDOWNLOAD_GTEST=OFF
        -DDOWNLOAD_GBENCHMARK=OFF
        -DDEFAULT_COLUMN_MAJOR=OFF
        -DDISABLE_VS2017=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
