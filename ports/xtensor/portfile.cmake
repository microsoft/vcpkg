# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xtensor
    REF 0.20.5
    SHA512 038f6858bea33a0b6e3b6622c9bbb316864335f7190ef64455ec0a062c13bcafcf215c089bbdf1f72acca63c50ceb2f1d11eb4874d82a5bfff3eead10cbfc00c
    HEAD_REF master
)

if("xsimd" IN_LIST FEATURES)
    set(XTENSOR_USE_XSIMD ON)
else()
    set(XTENSOR_USE_XSIMD OFF)
endif()

if("tbb" IN_LIST FEATURES)
    set(XTENSOR_USE_TBB ON)
else()
    set(XTENSOR_USE_TBB OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DXTENSOR_USE_XSIMD=${XTENSOR_USE_XSIMD}
        -DXTENSOR_USE_TBB=${XTENSOR_USE_TBB}
        -DXTENSOR_ENABLE_ASSERT=OFF
        -DXTENSOR_CHECK_DIMENSION=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARK=OFF
        -DDOWNLOAD_GTEST=OFF
        -DDOWNLOAD_GBENCHMARK=OFF
        -DDEFAULT_COLUMN_MAJOR=OFF
        -DDISABLE_VS2017=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME ${PORT})
