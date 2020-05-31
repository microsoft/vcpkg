vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Pavel_Kisliak/BitSerializer
    REF 0.10
    SHA512 518edee6b9cfc44ab5a28128aff82c4f84d5484aa4ffb609ebb286cd46f451f24a0823156692e5d8e7de7bbb40d70fcdd0d246791a45237966bc06775047488a
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "cpprestjson-archive"  BUILD_CPPRESTJSON_ARCHIVE
    "rapidjson-archive"    BUILD_RAPIDJSON_ARCHIVE
    "pugixml-archive"      BUILD_PUGIXML_ARCHIVE
    "rapidyaml-archive"    BUILD_RAPIDYAML_ARCHIVE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/bitserializer)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
