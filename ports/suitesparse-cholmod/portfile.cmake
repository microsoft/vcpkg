vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.12.2
    SHA512 0a7d070c90ef0a55c3ed821edf6567f4a84d5615250898b8fbacad19e1cf53dba199c38369c771465b4149ba5501bf0c1ae1352f29d0fb462fd10ca90e486cfa
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

if (CHOLMOD_USE_CUDA)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    )
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
        -DSUITESPARSE_USE_STRICT=ON
        -DSUITESPARSE_USE_FORTRAN=OFF
        -DSUITESPARSE_DEMOS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME ${PACKAGE_NAME}
    CONFIG_PATH lib/cmake/${PACKAGE_NAME}
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/${PACKAGE_NAME}/Doc/License.txt")
