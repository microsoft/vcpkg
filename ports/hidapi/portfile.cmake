vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF hidapi-${VERSION}
    SHA512 071d00eab861a18a05664e5a2e81beb332df06fb40feeba72b64e3f70c1e0772e2556f8ae5677e2340a5417fc6109ef450bcb67e74f5529d3984d4a7c10b433e
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "pp-data-dump"           HIDAPI_BUILD_PP_DATA_DUMP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHIDAPI_BUILD_HIDTEST=OFF
        -DHIDAPI_WITH_TESTS=OFF
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        # Windows only
        HIDAPI_BUILD_PP_DATA_DUMP
        HIDAPI_WITH_TESTS
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if ("pp-data-dump" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES pp_data_dump AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-bsd.txt")
