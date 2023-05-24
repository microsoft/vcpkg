#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/rapidjson
    REF 949c771b03de448bdedea80c44a4a5f65284bfeb # accessed on 2023-04-27
    SHA512 dc0a16230188ccd3ef8f1abffb3213948dd34b17df68330a28bb82a4e3f636e13add3ff33f03774322697140456c704223102e6517d5122fa099260704b7c363
    FILE_DISAMBIGUATOR 2
    HEAD_REF master
)

# Use RapidJSON's own build process, skipping examples and tests
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRAPIDJSON_BUILD_DOC=OFF
        -DRAPIDJSON_BUILD_EXAMPLES=OFF
        -DRAPIDJSON_BUILD_TESTS=OFF
)
vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/RapidJSON)
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
endif()

file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/RapidJSONConfig.cmake" _contents)
string(REPLACE "\${RapidJSON_SOURCE_DIR}" "\${RapidJSON_CMAKE_DIR}/../.." _contents "${_contents}")
string(REPLACE "set( RapidJSON_SOURCE_DIR \"${SOURCE_PATH}\")" "" _contents "${_contents}")
string(REPLACE "set( RapidJSON_DIR \"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel\")" "" _contents "${_contents}")
string(REPLACE "\${RapidJSON_CMAKE_DIR}/../../../include" "\${RapidJSON_CMAKE_DIR}/../../include" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/RapidJSONConfig.cmake" "${_contents}\nset(RAPIDJSON_INCLUDE_DIRS \"\${RapidJSON_INCLUDE_DIRS}\")\n")

file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
