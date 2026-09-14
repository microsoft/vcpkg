vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/GraphBLAS
    REF v10.5.1
    SHA512 6b4ce84e99864eb9c94866e9b448938854679ce0c77a2f5c7e160b087645c78fdc2ed749cfa40f23762c8f58aabaf141831fa5319ef83b901261547c6456653e
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
