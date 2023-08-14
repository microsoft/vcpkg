# All components of BitSerializer is "header only" except CSV archive
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Pavel_Kisliak/BitSerializer
    REF 0.50
    SHA512 d223e4487251e375b2f5d8b1dca9a3db3f5661c3eb308b12f019864e49d58fb0b7d45a45c3e7e232ba1d023adb1f9a3a287255099b205f57c6cade04167119d6
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "cpprestjson-archive"  BUILD_CPPRESTJSON_ARCHIVE
        "rapidjson-archive"    BUILD_RAPIDJSON_ARCHIVE
        "pugixml-archive"      BUILD_PUGIXML_ARCHIVE
        "rapidyaml-archive"    BUILD_RAPIDYAML_ARCHIVE
        "csv-archive"          BUILD_CSV_ARCHIVE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if (NOT ${BUILD_CSV_ARCHIVE})
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")