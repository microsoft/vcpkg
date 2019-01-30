include(vcpkg_common_functions)

set(SOURCE_VERSION 3.5.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nlohmann/json
    REF v${SOURCE_VERSION}
    SHA512 e2874e10e12070e8e1b9c01f41ce24002a3859c4aca8bf46083ea08e68f44ed6725bdcdf8e592b1e50d69975d506836c62a8e10fc6da00f0844c149dd6676996
    HEAD_REF master
)

vcpkg_replace_string(${SOURCE_PATH}/CMakeLists.txt "project(nlohmann-json" "project(nlohmann_json")

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
file(RENAME
    ${CURRENT_PACKAGES_DIR}/nlohmann_json.natvis
    ${CURRENT_PACKAGES_DIR}/share/nlohmann_json/nlohmann_json.natvis
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/nlohmann-json RENAME copyright)