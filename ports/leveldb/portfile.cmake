vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/leveldb
    REF 1.22
    SHA512 f9bbf5f466e7f707b94e19261762319ea9f65d41911690e84f59098551e2e69beccf756a414d705ade74ee96fd979bdb8b94c171c6f2cc83873cbd4a9380dbab
    HEAD_REF master
    PATCHES
        fix_config.patch
        fix-dependencies.patch
)

file(COPY "${CURRENT_PORT_DIR}/leveldbConfig.cmake.in" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        crc32c WITH_CRC32C
        snappy WITH_SNAPPY
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLEVELDB_BUILD_TESTS=OFF
        -DLEVELDB_BUILD_BENCHMARKS=OFF
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
