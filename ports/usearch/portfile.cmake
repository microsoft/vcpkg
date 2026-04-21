vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unum-cloud/usearch
    REF "v${VERSION}"
    SHA512 d2ba01c86a102b23aa2827392bc4759d33cf6bcd7e7a1baa35cff9c2100721726c7bff854d8d06065095d480dc2a8c2245fe7afe404d53b577b7a9c9446fb8c0
    HEAD_REF main
    PATCHES
        use-vcpkg-ports.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fp16     USEARCH_USE_FP16LIB
        jemalloc USEARCH_USE_JEMALLOC
        simsimd  USEARCH_USE_SIMSIMD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSEARCH_INSTALL=ON
        -DUSEARCH_BUILD_TEST_CPP=OFF
        -DUSEARCH_BUILD_BENCH_CPP=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/usearch)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
