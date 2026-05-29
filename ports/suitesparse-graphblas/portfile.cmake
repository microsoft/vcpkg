vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/GraphBLAS
    REF v10.3.1
    SHA512 a23a00d6dcab445ffe745c351fe870174b1fe0753ba048143b2494da20358a407252c4e72ac3666a43f683c59f19f5651d650deca4d5493b1ceef11514ddbe61
    HEAD_REF stable
    PATCHES
        crossbuild.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp      GRAPHBLAS_USE_OPENMP
    INVERTED_FEATURES
        precompiled GRAPHBLAS_COMPACT
)

if(VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS "-DGRB_JITPACKAGE_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/grb_jitpackage${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

# Prevent JIT cache from being created at ~/.SuiteSparse by default. Only used during build.
# see https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/v7.8.1/GraphBLAS/cmake_modules/GraphBLAS_JIT_paths.cmake
set(ENV{GRAPHBLAS_CACHE_PATH} "${CURRENT_BUILDTREES_DIR}/cache")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DSUITESPARSE_USE_CUDA=OFF
        -DSUITESPARSE_USE_STRICT=ON
        -DSUITESPARSE_USE_FORTRAN=OFF
        -DSUITESPARSE_DEMOS=OFF
        -DGRAPHBLAS_JIT_ENABLE_RELOCATE=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/GraphBLAS" PACKAGE_NAME "graphblas")
vcpkg_fixup_pkgconfig()

if(NOT VCPKG_CROSSCOMPILING)
    vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES grb_jitpackage DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
