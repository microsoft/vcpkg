# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor-blas
    REF 2876b041a2759f10dfde13ab3a2fc09578ae4b40 # 0.17.2
    SHA512 64c78d093f24fc15715bc7dfa486cfb1342a6752ea497f43553d031fc8be30718d01157e5b6412c516e6ce2be9045a89963d912e60f4eb7431675331b8ed6f90
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
