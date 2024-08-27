vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.8.1
    SHA512 d07709ad8567e5fe954f04d0c38a95a5610394aaa5ff5c809518c378b937d20556114b95c9dc052b316c8e8fcbb2eca294b425b21e8bbfa5c04f72c6f15a5eb6
    HEAD_REF dev
)

set(PACKAGE_NAME CHOLMOD)

configure_file(
    "${CURRENT_INSTALLED_DIR}/share/suitesparse/SuiteSparseBLAS.cmake"
    "${SOURCE_PATH}/SuiteSparse_config/cmake_modules/SuiteSparseBLAS.cmake"
    COPYONLY
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    matrixops  CHOLMOD_MATRIXOPS
    modify     CHOLMOD_MODIFY
    partition  CHOLMOD_PARTITION
    supernodal CHOLMOD_SUPERNODAL
    openmp     CHOLMOD_USE_OPENMP
)

set(CUDA_ENABLED OFF)
if("cuda" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "native")
endif()
if("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "all-major")
endif()

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
        -DSUITESPARSE_USE_OPENMP=OFF
        -DSUITESPARSE_USE_CUDA=${CUDA_ENABLED}
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
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
