include(vcpkg_common_functions)

set(JSON_DTO_VERSION 0.2.5)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/json_dto-${JSON_DTO_VERSION}-vcpkg)

vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/sobjectizerteam/json_dto-0.2/downloads/json_dto-${JSON_DTO_VERSION}-vcpkg.zip"
    FILENAME "json_dto-${JSON_DTO_VERSION}-vcpkg.zip"
    SHA512 cc21f2abc2799cb9f1c95ae3ae3512869e33d7d0b79c3e05e71d6f0a4376dcf948d89a4d71fe4266efa9d84c19c8a4b8ca2bc8d3d8c217df9ba4e6b87e50c33e
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/dev
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DJSON_DTO_INSTALL=ON
        -DJSON_DTO_TEST=OFF
        -DJSON_DTO_SAMPLE=OFF
        -DJSON_DTO_INSTALL_SAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/json-dto")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/json-dto)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/json-dto/LICENSE ${CURRENT_PACKAGES_DIR}/share/json-dto/copyright)
