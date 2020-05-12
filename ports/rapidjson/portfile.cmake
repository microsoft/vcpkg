#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/rapidjson
    REF 3b638e67150783303aebf1fc0789d6c44a026b53
    SHA512 743ff74448c1ac31d1d03c90aa50cd6119b9e1723e618d0ca1f6021ec8a5282b34e1fc13b8577d7cf9eee064b6d9f809b0c92fdc09581c96dfd69cf7b7805223
    HEAD_REF master
)

# Use RapidJSON's own build process, skipping examples and tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRAPIDJSON_BUILD_DOC:BOOL=OFF
        -DRAPIDJSON_BUILD_EXAMPLES:BOOL=OFF
        -DRAPIDJSON_BUILD_TESTS:BOOL=OFF
        -DCMAKE_INSTALL_DIR:STRING=cmake
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/doc)

file(READ "${CURRENT_PACKAGES_DIR}/share/rapidjson/RapidJSONConfig.cmake" _contents)
string(REPLACE "\${RapidJSON_SOURCE_DIR}" "\${RapidJSON_CMAKE_DIR}/../.." _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/rapidjson/RapidJSONConfig.cmake" "${_contents}\nset(RAPIDJSON_INCLUDE_DIRS \"\${RapidJSON_INCLUDE_DIRS}\")\n")

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

