include(vcpkg_common_functions)
set(VERSION 0.14.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/uwebsockets-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/uWebSockets/uWebSockets/archive/v${VERSION}.zip"
    FILENAME "uwebsockets-v${VERSION}.zip"
    SHA512 1fb798ba49b45c48991ef3c657da9ef8f46d18009c77d9a2c6b98345f97ad7d7806e5490dc478dd5d05bc92bbeb849ac5a300fb91028f786274da89587c04c6e
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/uwebsockets)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/uwebsockets/LICENSE ${CURRENT_PACKAGES_DIR}/share/uwebsockets/copyright)

vcpkg_copy_pdbs()
