vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/SuiteSparse
    REF v7.8.1
    SHA512 d07709ad8567e5fe954f04d0c38a95a5610394aaa5ff5c809518c378b937d20556114b95c9dc052b316c8e8fcbb2eca294b425b21e8bbfa5c04f72c6f15a5eb6
    HEAD_REF dev
)

set(PACKAGE_NAME SPQR)

configure_file(
    "${CURRENT_INSTALLED_DIR}/share/suitesparse/SuiteSparseBLAS.cmake"
    "${SOURCE_PATH}/SuiteSparse_config/cmake_modules/SuiteSparseBLAS.cmake"
    COPYONLY
)

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
