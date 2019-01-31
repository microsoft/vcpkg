# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xtensor
    REF ca0cfdbde852ee61a3ef20076e2733030f3d6479
    SHA512 d960a3c1c3e6c9250c6bc5ed4e641486980a3ffa4179696eabb92fee50673901324cd2174b76cbd74ab07e6f3c175a26cb564b3087863602c3dce0a83a263da6
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
