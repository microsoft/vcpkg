if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ClickHouse/clickhouse-cpp
    REF "v${VERSION}"
    SHA512 3b6d76a541d75e3565b3d196193ac04baa7e99c54fd175deeb5bb143f9192243966c7d82a5c3159760d8b77f9e3d6b88254bce9ee58af53505dc0c5dc6e429a6
    HEAD_REF master
    PATCHES
        fix-deps-and-build-type.patch
        werror.patch
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
