include(vcpkg_common_functions)
set(SOURCE_VERSION 2.1.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/json-${SOURCE_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/nlohmann/json/archive/v${SOURCE_VERSION}.zip"
    FILENAME "nlohmann-json-v${SOURCE_VERSION}.zip"
    SHA512 7f7155c4bcc4f704f329ba6976c31888a45d17bc2fa08ee9e64dc1b0b1f39439819b895cda9d77f3f60446ad6f5802e9c6ae79fbaf6d1b6f7e49ca050b86cd7c
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(COPY ${SOURCE_PATH}/LICENSE.MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/nlohmann-json)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nlohmann-json/LICENSE.MIT ${CURRENT_PACKAGES_DIR}/share/nlohmann-json/copyright)
