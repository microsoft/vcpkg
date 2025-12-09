if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ClickHouse/clickhouse-cpp
    REF "v${VERSION}"
    SHA512 4199ac2848b0544a2a9c4e03ca62f9a14e13652b09df62b2c95eda59c567cb8227099b9cb027f18d7bdb3a25ee41f01301a551f1bf98727bf89766f5e1cac3f5
    HEAD_REF master
    PATCHES
        fix-deps-and-build-type.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl WITH_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DWITH_SYSTEM_ABSEIL=ON
        -DWITH_SYSTEM_LZ4=ON
        -DWITH_SYSTEM_CITYHASH=ON
        -DWITH_SYSTEM_ZSTD=ON
        -DDEBUG_DEPENDENCIES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
