vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/GraphBLAS
    REF v${VERSION}
    SHA512 70bbf2331cdc013ef18456712a823e2f95e8f1773933f94bc55e5b7e1bc8a225bf56b21d9b66caabaf98ee909975820b0d899101289642c6e50253892c5af48e
    HEAD_REF stable
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    compact GRAPHBLAS_COMPACT
    openmp  GRAPHBLAS_USE_OPENMP
)

# Prevent JIT cache from being created at ~/.SuiteSparse by default. Only used during build.
# see https://github.com/DrTimothyAldenDavis/SuiteSparse/blob/v7.7.0/GraphBLAS/cmake_modules/GraphBLAS_JIT_paths.cmake
vcpkg_backup_env_variables(VARS GRAPHBLAS_CACHE_PATH)
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

vcpkg_restore_env_variables(VARS GRAPHBLAS_CACHE_PATH)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME GraphBLAS
    CONFIG_PATH lib/cmake/GraphBLAS
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
