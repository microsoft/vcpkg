vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nlohmann/json
    REF "v${VERSION}"
    SHA512 7df19b621de34f08d5d5c0a25e8225975980841ef2e48536abcf22526ed7fb99f88ad954a2cb823115db59ccc88d1dbe74fe6c281b5644b976b33fb78db9d717
    HEAD_REF master
)

if(NOT DEFINED nlohmann-json_IMPLICIT_CONVERSIONS)
    set(nlohmann-json_IMPLICIT_CONVERSIONS ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "diagnostics"           JSON_Diagnostics
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DJSON_Install=ON
        -DJSON_MultipleHeaders=ON
        -DJSON_BuildTests=OFF
        -DJSON_ImplicitConversions=${nlohmann-json_IMPLICIT_CONVERSIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "nlohmann_json" CONFIG_PATH "share/cmake/nlohmann_json")
vcpkg_fixup_pkgconfig()

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/nlohmann_json/nlohmann_jsonTargets.cmake"
    "{_IMPORT_PREFIX}/nlohmann_json.natvis"
    "{_IMPORT_PREFIX}/share/nlohmann_json/nlohmann_json.natvis"
    IGNORE_UNCHANGED
)
if(EXISTS "${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis")
    file(RENAME
        "${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis"
        "${CURRENT_PACKAGES_DIR}/share/nlohmann_json/nlohmann_json.natvis"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Handle usage
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
