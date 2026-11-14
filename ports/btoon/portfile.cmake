vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BTOON-project/btoon-core
    REF "v${VERSION}"
    SHA512 cee47b8f3735c20666934964a5fbdfdc04162f319e7ce9c0db6e216caf3e884a712c084d65ef1a38a3fac4c6a349eede4050440a676a2e7f7bbc252dd1b0c229
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
