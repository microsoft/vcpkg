vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DrTimothyAldenDavis/GraphBLAS
    REF v${VERSION}
    SHA512 b43b3dc34e392a39de7112133e061ee5831017dde2f1cbfad7381abbbc0123740deb319b877ad891c5674caa0bdf0d5c7966780107dfad28eb89735af5bd8840
    HEAD_REF stable
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp      GRAPHBLAS_USE_OPENMP
    INVERTED_FEATURES
        precompiled GRAPHBLAS_COMPACT
)

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

vcpkg_cmake_config_fixup(
    PACKAGE_NAME GraphBLAS
    CONFIG_PATH lib/cmake/GraphBLAS
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
