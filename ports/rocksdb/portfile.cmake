vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebook/rocksdb
  REF bf2c335184de16a3cc1787fa97ef9f22f7114238 # v7.8.3
  SHA512 436ab1f16ddc931267d45a49449efd25cd9e11b340fa8bdb1c89f9a269b0e2479e3c9cfebdf35c0acf7bc60d090d23c8d131a74769891fe4192cfcdabe0563a1
  HEAD_REF main
  PATCHES
    0002-only-build-one-flavor.patch
    0003-use-find-package.patch
    0004-fix-dependency-in-config.patch
    0005-do-not-install-cmake-modules.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WITH_MD_LIBRARY)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ROCKSDB_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
      "lz4"     WITH_LZ4
      "snappy"  WITH_SNAPPY
      "zlib"    WITH_ZLIB
      "zstd"    WITH_ZSTD
      "bzip2"   WITH_BZ2
      "tbb"     WITH_TBB
  INVERTED_FEATURES
      "tbb"     CMAKE_DISABLE_FIND_PACKAGE_TBB
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DWITH_GFLAGS=OFF
    -DWITH_TESTS=OFF
    -DWITH_BENCHMARK_TOOLS=OFF
    -DWITH_TOOLS=OFF
    -DWITH_FOLLY_DISTRIBUTED_MUTEX=OFF
    -DUSE_RTTI=1
    -DROCKSDB_INSTALL_ON_WINDOWS=ON
    -DFAIL_ON_WARNINGS=OFF
    -DWITH_MD_LIBRARY=${WITH_MD_LIBRARY}
    -DPORTABLE=ON
    -DCMAKE_DEBUG_POSTFIX=d
    -DROCKSDB_BUILD_SHARED=${ROCKSDB_BUILD_SHARED}
    -DCMAKE_DISABLE_FIND_PACKAGE_NUMA=TRUE
    -DCMAKE_DISABLE_FIND_PACKAGE_gtest=TRUE
    -DCMAKE_DISABLE_FIND_PACKAGE_Git=TRUE
    ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rocksdb)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE.Apache" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/LICENSE.leveldb" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
