vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  "Reference-LAPACK/lapack"
    REF "v${VERSION}"
    SHA512 f8f3c733a0221be0b3f5618235408ac59cbd4e5f1c4eab5f509b831a6ec6a9ef14b8849aa6ea10810df1aff90186ca454d15e9438d1dd271c2449d42d3da9dda
    HEAD_REF master
    PATCHES
        cmake-config.diff
        win32-library-prefix.diff
        tmglib.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        tmg     LAPACKE_WITH_TMG
)

if(LAPACKE_WITH_TMG)
    # enable config check for dlatms
    include(vcpkg_find_fortran)
    vcpkg_find_fortran(FORTRAN_CMAKE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DLAPACKE=ON
        -DUSE_OPTIMIZED_BLAS=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_BLAS=ON
        -DUSE_OPTIMIZED_LAPACK=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_LAPACK=ON
        -DTEST_FORTRAN_COMPILER=OFF
)

vcpkg_cmake_install()

file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/lapack.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/lapack.pc")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake/lapack-${VERSION}" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/lapack-${VERSION}")
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/lapacke-${VERSION}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LAPACKE/LICENSE")
