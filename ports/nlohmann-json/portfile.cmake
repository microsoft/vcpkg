vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nlohmann/json
    REF v3.11.2
    SHA512 70097c9bcd7a91254acbd41b8b68a6aaa371fc2dd7011f472917f69f1e2d2986155a0339dad791699d542e4a3be44dc49ae72ff73d0ee0ea4b34183296ce19a0 
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
