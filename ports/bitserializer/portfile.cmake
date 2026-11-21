# All BitSerializer components are "header only" except for JSON, CSV and MsgPack archives.
# Don't use vcpkg_from_github: the release asset is the immutable source archive.
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/PavelKisliak/BitSerializer/releases/download/v${VERSION}/bitserializer_v${VERSION}_src.tar.gz"
    FILENAME "bitserializer-${VERSION}-src.tar.gz"
    SHA512 e25ad5c5b391bafb30df7bc2adea4f7e67bc0b97caaf8fc0f9cda9047991100b97a08a6b0265eed13660ed8df8adb0a2a061fb9c6f2b5b84f0f1f8105e73c4ed
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "rapidjson-archive"    BUILD_RAPIDJSON_ARCHIVE
        "pugixml-archive"      BUILD_PUGIXML_ARCHIVE
        "rapidyaml-archive"    BUILD_RAPIDYAML_ARCHIVE
        "csv-archive"          BUILD_CSV_ARCHIVE
        "msgpack-archive"      BUILD_MSGPACK_ARCHIVE
        "json-archive"         BUILD_JSON_ARCHIVE
)

if(NOT "fast-float" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_FastFloat=ON")
endif()

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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(NOT (BUILD_JSON_ARCHIVE OR BUILD_CSV_ARCHIVE OR BUILD_MSGPACK_ARCHIVE))
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
