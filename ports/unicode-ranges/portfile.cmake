vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cristi1990an/unicode_ranges
    REF "v${VERSION}"
    SHA512 85c9d03c45347e8cba8c01f94d016fc107cdf39acae048e746b91d0679a6be787903e1398a9c7b9b448de49aecc465efb6bcd9940fce8009b1387dc0a4620385
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        icu UTF8_RANGES_ENABLE_ICU
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUTF8_RANGES_BUILD_TESTS=OFF
        -DUTF8_RANGES_BUILD_BENCHMARKS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME unicode_ranges
    CONFIG_PATH lib/cmake/unicode_ranges
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSE-MIT"
        "${SOURCE_PATH}/LICENSE-APACHE"
        "${SOURCE_PATH}/THIRD_PARTY_NOTICES.md"
)
