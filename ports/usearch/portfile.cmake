vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unum-cloud/usearch
    REF "v${VERSION}"
    SHA512 6aa32a96f5f672aa57287257133aa8931b13b8738aaa156bee24c77d9b5340d1d9720aaaad099946b3e7b6b35522f10241a30cd4084a641d658158c9d4b53453
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
