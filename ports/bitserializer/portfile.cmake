# All BitSerializer components are "header only" except for CSV and MsgPack archives
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PavelKisliak/BitSerializer
    REF v0.80
    SHA512 43d0bbfeefaf303d20c2bf0534b7fab7bcb8508999ff346c7978b67aa8103a2fc7423d306d15cbd9824921c7055221ef2f8ad9cd2564ef7e032157ab9bb8e041
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