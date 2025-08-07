vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF hidapi-${VERSION}
    SHA512 a4ddd13a80a84956872fa52aa861b40e4959f301d8d91afe0feaf9dbd87394561e1fdd20cbf8cf47200845f80a8db8a934bc2e3025fe6f16435e37c17621e7b6
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
