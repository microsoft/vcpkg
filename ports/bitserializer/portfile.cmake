# All components of BitSerializer is "header only" except CSV archive
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PavelKisliak/BitSerializer
    REF v0.70
    SHA512 efd6d9e00bbbe9ef541b2bea8ee8417befcc6482e96241689f39ab130743a1e3fbf2e22ae81c4291d15091f63f94f20964ad873a8601c2f5d98e7021aaedc793
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "cpprestjson-archive"  BUILD_CPPRESTJSON_ARCHIVE
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