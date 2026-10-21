# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor-blas
    REF "${VERSION}"
    SHA512 4fcc5e485a2ddd9fee48dda75a38b976355c40a5e4722d4bc1e9fefa231c6c38f97afffeaef510c6c2290cf1f29cbbae889a131d121278055d23374d72d09712
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS_RELEASE
        -DCXXBLAS_DEBUG=OFF
    OPTIONS_DEBUG
        -DCXXBLAS_DEBUG=ON
    OPTIONS
        -DXTENSOR_USE_FLENS_BLAS=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARK=OFF
)

vcpkg_cmake_install()

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/xtensor-blas/xblas_config_cling.hpp")

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/xflens/cxxblas/netlib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
