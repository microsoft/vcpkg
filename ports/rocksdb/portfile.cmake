vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebook/rocksdb
  REF fdf403f5918a2b4355cf75ebe5e21d0fc22db880 # v8.0.0
  SHA512 bcc0d49f0ec7208bb7b114460fb501c056091c98e0175b50ab1f9ac802ce3b1039d7ab23966c38da4efaa871a833dfd15c69ae75c866a052ec4124234c0818f8
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
    "jemalloc" WITH_JEMALLOC
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
    -DPORTABLE=ON
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

file(INSTALL "${SOURCE_PATH}/LICENSE.Apache" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/LICENSE.leveldb" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
