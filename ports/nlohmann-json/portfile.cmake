vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nlohmann/json
    REF v3.10.2
    SHA512 9a399dfc8aab19c9fc12470e8087895b1c05d48a9bcc731b483d8670c361cffb2adc3ccced822b7f17255e88387a441d619c4e1f1afeb702d1d035ad24fe22ed
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DJSON_Install=ON
        -DJSON_MultipleHeaders=ON
        -DJSON_BuildTests=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "nlohmann_json" CONFIG_PATH "lib/cmake/nlohmann_json")
vcpkg_fixup_pkgconfig()

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/nlohmann_json/nlohmann_jsonTargets.cmake"
    "{_IMPORT_PREFIX}/nlohmann_json.natvis"
    "{_IMPORT_PREFIX}/share/nlohmann_json/nlohmann_json.natvis"
)
if(EXISTS ${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis)
    file(RENAME
        "${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis"
        "${CURRENT_PACKAGES_DIR}/share/nlohmann_json/nlohmann_json.natvis"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/nlohmann_json.natvis")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
