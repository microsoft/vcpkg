vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BTOON-project/btoon-core
    REF "v${VERSION}"
    SHA512 65b2b6106c87e690a8d13dbfe5f5d36c39373492d47b90a890b908e33a7439b6b22738fe92178e54b5e69135b63f8bea593e1b798ebd1d982f467cd62d399e08
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
