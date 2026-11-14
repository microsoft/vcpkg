vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BTOON-project/btoon-core
    REF "v${VERSION}"
    SHA512 adb97d6f5ebb81b15955cc036b190de2689f7d864c3b600c83abd8cc2a27ae8aa6bd938c80d751403f803f339995f2e9901fd35f1f82b57ff62b632620d89833
    HEAD_REF main
)
# Only the command-line tools use the vendored nlohmann/json; make sure nothing else can.
file(REMOVE_RECURSE "${SOURCE_PATH}/include/third_party")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        brotli  BTOON_WITH_BROTLI
        lz4     BTOON_WITH_LZ4
        snappy  BTOON_WITH_SNAPPY
        zstd    BTOON_WITH_ZSTD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_TOOLS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBTOON_BUNDLED_ZLIB=OFF
        -DBTOON_INSTALL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/btoon)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
