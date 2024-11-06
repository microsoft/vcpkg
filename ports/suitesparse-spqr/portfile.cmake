vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.8.3
    SHA512 fc0fd0aaf55a6712a3b8ca23bf7536a31d52033e090370ebbf291f05d0e073c7dcfd991a80b037f54663f524804582b87af86522c2e4435091527f0d3c189244
    HEAD_REF dev
    PATCHES
        001-dont-override-cuda-architectures.patch
)

set(PACKAGE_NAME SPQR)

configure_file(
    "${CURRENT_INSTALLED_DIR}/share/suitesparse/SuiteSparseBLAS.cmake"
    "${SOURCE_PATH}/SuiteSparse_config/cmake_modules/SuiteSparseBLAS.cmake"
    COPYONLY
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda  SPQR_USE_CUDA
        cuda  SUITESPARSE_USE_CUDA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/${PACKAGE_NAME}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}
        -DSUITESPARSE_USE_STRICT=ON
        -DSUITESPARSE_USE_FORTRAN=OFF
        -DSUITESPARSE_DEMOS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if("cuda" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME SuiteSparse_GPURuntime
        CONFIG_PATH lib/cmake/SuiteSparse_GPURuntime
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME GPUQREngine
        CONFIG_PATH lib/cmake/GPUQREngine
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ${PACKAGE_NAME}
    CONFIG_PATH lib/cmake/${PACKAGE_NAME}
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/${PACKAGE_NAME}/Doc/License.txt")
