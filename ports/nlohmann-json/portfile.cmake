vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nlohmann/json
    REF e7b3b40b5a95bc74b9a7f662830a27c49ffc01b4 # v3.7.3
    SHA512 b57dfb6ceda9de13e9da1bb5a6399c259bcdfd6c14f656c145126247459b4963109704e359bb565a2dc806356969f2af8e28a15b5fa9ed4cdcc993d586c91936
    HEAD_REF master
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DJSON_BuildTests=0
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nlohmann_json TARGET_PATH share/nlohmann_json)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/nlohmann_json/nlohmann_jsonTargets.cmake
    "{_IMPORT_PREFIX}/nlohmann_json.natvis"
    "{_IMPORT_PREFIX}/share/nlohmann_json/nlohmann_json.natvis"
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/lib
)

if(EXISTS ${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis
        ${CURRENT_PACKAGES_DIR}/share/nlohmann_json/nlohmann_json.natvis
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
