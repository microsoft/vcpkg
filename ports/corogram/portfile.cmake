vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO corogram/corogram
    REF "v${VERSION}"
    SHA512 a6760f037b18f4855458eb44c6bc5e97166df9ae5d16bd0bb75f6858341c524aae29be7c23928e5c59b94b8b2af15c85f3400c10c75512542f1ef18201639c77
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    redis COROGRAM_HAS_HIREDIS
    ed25519 COROGRAM_ED25519
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    ${FEATURE_OPTIONS}
    -DCOROGRAM_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME corogram
    CONFIG_PATH lib/cmake/corogram
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")