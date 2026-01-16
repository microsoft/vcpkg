# All BitSerializer components are "header only" except for CSV and MsgPack archives
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PavelKisliak/BitSerializer
    REF v0.85
    SHA512 a55d3948ad66cbd9328c2845fb954ac5587ae230be0276c15cdc5c2e23f7797149a955553a80ff001de79dc7db853f573360827f1a56d83dbd3f9ea249288932
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "rapidjson-archive"    BUILD_RAPIDJSON_ARCHIVE
        "pugixml-archive"      BUILD_PUGIXML_ARCHIVE
        "rapidyaml-archive"    BUILD_RAPIDYAML_ARCHIVE
        "csv-archive"          BUILD_CSV_ARCHIVE
        "msgpack-archive"      BUILD_MSGPACK_ARCHIVE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if (NOT (${BUILD_CSV_ARCHIVE} OR ${BUILD_MSGPACK_ARCHIVE}))
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")