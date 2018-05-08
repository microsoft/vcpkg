include(vcpkg_common_functions)

set(JSON_DTO_VERSION 0.3.0)

# set(SOURCE_PATH /media/kola/hddhome/bitbucket/drafts2018/json_dto-0.3-vcpkg)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/json_dto-${JSON_DTO_VERSION}-vcpkg)

vcpkg_download_distfile(ARCHIVE
    URLS "https://bitbucket.org/ngrodzitski/restinio-vcpkg-archives-tesst-2018/downloads/json_dto-0.3.0-vcpkg.zip"
    # URLS "https://bitbucket.org/sobjectizerteam/json_dto-0.3/downloads/json_dto-${JSON_DTO_VERSION}-vcpkg.zip"
    FILENAME "json_dto-${JSON_DTO_VERSION}-vcpkg.zip"
    SHA512 95e763ff14115c26e1801f21fb505c6761043cd1c1dfc42bd9765b7737931a5a234930c477d53ca0d3b588019922573b7ec20745a1307c9c81db3588fd0977b4
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/dev
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DJSON_DTO_INSTALL=ON
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
