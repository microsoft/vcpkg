#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tencent/rapidjson
    REF v1.1.0
    SHA512 2e82a4bddcd6c4669541f5945c2d240fb1b4fdd6e239200246d3dd50ce98733f0a4f6d3daa56f865d8c88779c036099c52a9ae85d47ad263686b68a88d832dff
    HEAD_REF master
    PATCHES arm64-endian.patch
)

# Use RapidJSON's own build process, skipping examples and tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DRAPIDJSON_BUILD_DOC:BOOL=OFF
        -DRAPIDJSON_BUILD_EXAMPLES:BOOL=OFF
        -DRAPIDJSON_BUILD_TESTS:BOOL=OFF
        -DCMAKE_INSTALL_DIR:STRING=cmake
)
vcpkg_install_cmake()

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

# Delete redundant directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/share/doc)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license.txt ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/rapidjson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rapidjson/license.txt ${CURRENT_PACKAGES_DIR}/share/rapidjson/copyright)
