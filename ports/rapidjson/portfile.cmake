#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/rapidjson
    REF 24b5e7a8b27f42fa16b96fc70aade9106cf7102f # accessed on 2025-02-26
    SHA512 50f8723414a6e63eadd45f97be5c44e9fff2d06216c8cc4df802f5bfc2a9416a039f2c69e9bb1882f7e756cd38a7097eea05cab76c739f45805dc41617140799
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
string(REPLACE "VERSION 3.0" "VERSION 3.5...3.30" _contents "${_contents}")
string(REPLACE "\${RapidJSON_SOURCE_DIR}" "\${RapidJSON_CMAKE_DIR}/../.." _contents "${_contents}")
string(REPLACE "set( RapidJSON_SOURCE_DIR \"${SOURCE_PATH}\")" "" _contents "${_contents}")
string(REPLACE "set( RapidJSON_DIR \"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel\")" "" _contents "${_contents}")
string(REPLACE "\${RapidJSON_CMAKE_DIR}/../../../include" "\${RapidJSON_CMAKE_DIR}/../../include" _contents "${_contents}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/RapidJSONConfig.cmake" "${_contents}\nset(RAPIDJSON_INCLUDE_DIRS \"\${RapidJSON_INCLUDE_DIRS}\")\n")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
