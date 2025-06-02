vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.8.3
    SHA512 fc0fd0aaf55a6712a3b8ca23bf7536a31d52033e090370ebbf291f05d0e073c7dcfd991a80b037f54663f524804582b87af86522c2e4435091527f0d3c189244
    HEAD_REF dev
    PATCHES
        001-dont-override-cuda-architectures.patch
)

set(PACKAGE_NAME CHOLMOD)

configure_file(
    "${CURRENT_INSTALLED_DIR}/share/suitesparse/SuiteSparseBLAS.cmake"
    "${SOURCE_PATH}/SuiteSparse_config/cmake_modules/SuiteSparseBLAS.cmake"
    COPYONLY
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda       CHOLMOD_USE_CUDA
        cuda       SUITESPARSE_USE_CUDA
        matrixops  CHOLMOD_MATRIXOPS
        modify     CHOLMOD_MODIFY
        partition  CHOLMOD_PARTITION
        supernodal CHOLMOD_SUPERNODAL
        openmp     CHOLMOD_USE_OPENMP
)

set(GPL_ENABLED OFF)
if(CHOLMOD_MATRIXOPS OR CHOLMOD_MODIFY OR CHOLMOD_SUPERNODAL OR CUDA_ENABLED)
    set(GPL_ENABLED ON)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/${PACKAGE_NAME}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DCHOLMOD_GPL=${GPL_ENABLED}
        -DSUITESPARSE_USE_STRICT=ON
        -DSUITESPARSE_USE_FORTRAN=OFF
        -DSUITESPARSE_DEMOS=OFF
        -DSUITESPARSE_USE_64BIT_BLAS=1
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME ${PACKAGE_NAME}
    CONFIG_PATH lib/cmake/${PACKAGE_NAME}
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/${PACKAGE_NAME}/Doc/License.txt")
