if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ClickHouse/clickhouse-cpp
    REF "v${VERSION}"
    SHA512 626cce4d6037cbeb86c5720ece7ac95c9ff0e561825e7907934669709091886d209f3128798db41a89ef3585d0639e40a5c4f96a0e724b6bee25291710ad391e
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
