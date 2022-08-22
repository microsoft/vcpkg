# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor
    REF 825c0fd8a465049c06ad89fa3911b342dbffcabf # 0.24.0
    SHA512 18b030efb88255108f3e2a0f5da9f082c32f2b637cb83fcabd5b579b0cff67b503d378037088c535497da09c00a5430ca87e737235b3b0b449da183925d99e68
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xsimd XTENSOR_USE_XSIMD
        tbb XTENSOR_USE_TBB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
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

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
