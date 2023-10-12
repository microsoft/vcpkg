if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ClickHouse/clickhouse-cpp
    REF "v${VERSION}"
    SHA512 2719c034a2dc2de7e992aa17859ea437551bfe89395e6a708a4549ed274f366aee0c0f0bcd90a690c15f5361a8f8198bb4f1d7d986da98c1d632489bcfb8bdd0
    HEAD_REF master
    PATCHES
        fix-deps-and-build-type.patch
        fix-timeval.patch
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
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
