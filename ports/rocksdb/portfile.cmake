vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebook/rocksdb
  REF "v${VERSION}"
  SHA512 4e211fb6f2534ef8ccf71648c5a0fa8a16647d868ac3b62f68c6bd0b26abb6aae7e80c26bb9501faea6c9ac6dfc31e20d11a093695aa5ced3c9e8c2c04fcdb3d
  HEAD_REF main
  PATCHES
    0001-fix-dependencies.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WITH_MD_LIBRARY)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ROCKSDB_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    "liburing" WITH_LIBURING
    "snappy" WITH_SNAPPY
    "lz4" WITH_LZ4
    "zlib" WITH_ZLIB
    "zstd" WITH_ZSTD
    "bzip2" WITH_BZ2
    "numa" WITH_NUMA
    "tbb" WITH_TBB
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DWITH_GFLAGS=OFF
    -DWITH_TESTS=OFF
    -DWITH_BENCHMARK_TOOLS=OFF
    -DWITH_TOOLS=OFF
    -DUSE_RTTI=ON
    -DROCKSDB_INSTALL_ON_WINDOWS=ON
    -DFAIL_ON_WARNINGS=OFF
    -DWITH_MD_LIBRARY=${WITH_MD_LIBRARY}
    -DPORTABLE=1 # Minimum CPU arch to support, or 0 = current CPU, 1 = baseline CPU
    -DROCKSDB_BUILD_SHARED=${ROCKSDB_BUILD_SHARED}
    -DCMAKE_DISABLE_FIND_PACKAGE_Git=TRUE
    ${FEATURE_OPTIONS}
  OPTIONS_DEBUG
    -DCMAKE_DEBUG_POSTFIX=d
    -DWITH_RUNTIME_DEBUG=ON
  OPTIONS_RELEASE
    -DWITH_RUNTIME_DEBUG=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rocksdb)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(COMMENT [[
RocksDB is dual-licensed under both the GPLv2 (found in COPYING)
and Apache 2.0 License (found in LICENSE.Apache). You may select,
at your option, one of the above-listed licenses.
]]
  FILE_LIST
    "${SOURCE_PATH}/LICENSE.leveldb"
    "${SOURCE_PATH}/LICENSE.Apache"
    "${SOURCE_PATH}/COPYING"
)
