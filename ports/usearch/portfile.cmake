vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unum-cloud/usearch
    REF "v${VERSION}"
    SHA512 bbddcc500032c71e8e7563454baddf798cb8eb7bb96f4c6cab1137c86a8e0849701eb70d6e3b1329575d90faffa91656844a2a0205132f447ac9c2ffabc87e3c
    HEAD_REF main
    PATCHES
        use-vcpkg-ports.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        fp16     USEARCH_USE_FP16LIB
        jemalloc USEARCH_USE_JEMALLOC
        numkong  USEARCH_USE_NUMKONG
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
