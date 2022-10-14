# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor-blas
    REF 66ab0fa7cd53d0b914f89d4d451576a9240ea457 # 0.20.0
    SHA512 c95aa1388577ca74933c81e56322c9dae9c4d6b0493be60d5a3bfbaeaf769f6005542b5b0a24a6c6374007499113c2920870b01c4f5ea712ad78c2468964b6db
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS_RELEASE -DCXXBLAS_DEBUG=OFF
    OPTIONS_DEBUG -DCXXBLAS_DEBUG=ON
    OPTIONS
        -DXTENSOR_USE_FLENS_BLAS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARK=OFF
        -DDOWNLOAD_GTEST=OFF
        -DDOWNLOAD_GBENCHMARK=OFF
)

vcpkg_cmake_install()

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/xtensor-blas/xblas_config_cling.hpp")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/xflens/cxxblas/netlib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
