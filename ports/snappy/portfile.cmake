vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/snappy
    REF 2b63814b15a2aaae54b7943f0cd935892fae628f # 1.1.9
    SHA512 1494596d472de5fbee086ab6ab0586c83b14357fa735cf15ebdba63838a30e1183d33cd089dda8e7c9ee680535c2527ee1c22b5de6a2156e6c86ec8f748454a5
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test        SNAPPY_BUILD_TESTS
        benchmark   SNAPPY_BUILD_BENCHMARKS
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Snappy)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)