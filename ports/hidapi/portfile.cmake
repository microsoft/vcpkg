vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/hidapi
    REF hidapi-${VERSION}
    SHA512 66a045144f90b41438898b82f0398e80223323ebfe6e4f197d2713696bb3ae60f36aea5a37a9999b34b12294783fd7e4c28c6e785462559cbe21276009da1eac
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "pp-data-dump"           HIDAPI_BUILD_PP_DATA_DUMP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DHIDAPI_BUILD_HIDTEST=OFF
    ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if ("pp-data-dump" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES pp_data_dump AUTO_CLEAN)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/hidapi/libhidapi.cmake" "\"/hidapi\"" "\"\${_IMPORT_PREFIX}/include\"")

file(INSTALL "${SOURCE_PATH}/LICENSE-bsd.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
