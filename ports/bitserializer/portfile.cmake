# All components of BitSerializer is "header only" except CSV archive
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PavelKisliak/BitSerializer
    REF v0.65
    SHA512 fa49c6409b691c8e67fd2bf6ba740367334283bbfe3d984256420da3f9b439b56a04e718844466875b4cc01380d4d3a4ff3f3a6b347d3fd391895551eb8c8f91
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