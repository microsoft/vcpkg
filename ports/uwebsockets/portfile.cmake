include(vcpkg_common_functions)
set(VERSION 0.14.3)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/uwebsockets-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/uWebSockets/uWebSockets/archive/v${VERSION}.zip"
    FILENAME "uwebsockets-v${VERSION}.zip"
    SHA512 a64a6ee91d411f4285deb10b9b7620b4c4a2ff0f8137864380968349f7786c406ba44644b6ca589ee41c1e5adfa1ee1cf3697e54ecf5d459ab8bf69a3a4def7e
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
