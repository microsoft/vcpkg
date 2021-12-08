#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/rapidjson
    REF fd3dc29a5c2852df569e1ea81dbde2c412ac5051 # accessed on 2021-11-24
    SHA512 305014605dde1969a932254dbb48f3081e18805da2c97c16f319f162378d1bf64c1cfec0239fb423c5961a3b08a37abf05ede840d815ffaeadaae2a8a5a0c5c6
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
