#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yinqiwen/pbjson
    REF 5cb78413cb4d223e26a8c89d424b8c0623b79832
    SHA512 f332c09f1ad2e5575155eaa720c30bdba83efcd782bf1d8241d6c5ac678a69c97ce4e4a17f4cd016845903c5c3619109a20516bd1f85a74580407839d9cfb562
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

