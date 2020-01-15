# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor
    REF 8c77ea7fe479714a297efc0263c933a41fd2fc50 # 0.21.2
    SHA512 f535e3a5d9325b73af31b64a2c20f504d754202f2d557f63bab280a0b2c7e67d357f9a5c281a2cf73cccf0af129b29e38e218c95ab421c5473a92fe28bd9b2d6
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
