vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.7.0
    SHA512 aa62dae81ae423ce7162ae83b46e5cf606d95482e6c6bb7ae6d61e15987761119d9418ef3a96648e6ba2327871a2847eef8ace197aa375279d71c80329d6f451
    HEAD_REF dev
)

set(PACKAGE_NAME SPQR)

# Avoid overriding of BLA_VENDOR and skip straight to find_package() as done here
# https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/v7.7.0/SuiteSparse_config/cmake_modules/SuiteSparseBLAS.cmake#L240-L245
file(WRITE "${SOURCE_PATH}/SuiteSparse_config/cmake_modules/SuiteSparseBLAS.cmake" "find_package(BLAS REQUIRED)\nset(BLA_SIZEOF_INTEGER 4)\nset(SuiteSparse_BLAS_integer int32_t)\n")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

set(CUDA_ENABLED OFF)
if("cuda" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "native")
endif()
if("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "all-major")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/${PACKAGE_NAME}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DSUITESPARSE_USE_CUDA=${CUDA_ENABLED}
        -DSPQR_USE_CUDA=${CUDA_ENABLED}
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
        -DSUITESPARSE_USE_STRICT=ON
        -DSUITESPARSE_USE_FORTRAN=OFF
        -DSUITESPARSE_DEMOS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME ${PACKAGE_NAME}
    CONFIG_PATH lib/cmake/${PACKAGE_NAME}
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/${PACKAGE_NAME}/Doc/License.txt")
