#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/rapidjson
    REF 232389d4f1012dddec4ef84861face2d2ba85709 # accessed on 2022-06-28
    SHA512 60bfbfe4884122aa9ae8755531da18ce4a793bb217c06474dd8c5afe0f2f5df280c40be2f303c1740f5af14c7ad5cc2a57f08de5205cc7ab27d6166b0f49130d
    HEAD_REF master
)

# Use RapidJSON's own build process, skipping examples and tests
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRAPIDJSON_BUILD_DOC:BOOL=OFF
        -DRAPIDJSON_BUILD_EXAMPLES:BOOL=OFF
        -DRAPIDJSON_BUILD_TESTS:BOOL=OFF
        -DCMAKE_INSTALL_DIR:STRING=cmake
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/share/doc")

file(READ "${CURRENT_PACKAGES_DIR}/share/rapidjson/RapidJSONConfig.cmake" _contents)
string(REPLACE "\${RapidJSON_SOURCE_DIR}" "\${RapidJSON_CMAKE_DIR}/../.." _contents "${_contents}")
string(REPLACE "set( RapidJSON_SOURCE_DIR \"${SOURCE_PATH}\")" "" _contents "${_contents}")
string(REPLACE "set( RapidJSON_DIR \"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel\")" "" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/rapidjson/RapidJSONConfig.cmake" "${_contents}\nset(RAPIDJSON_INCLUDE_DIRS \"\${RapidJSON_INCLUDE_DIRS}\")\n")

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
