include(vcpkg_common_functions)
set(VERSION 0.14.2)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/uwebsockets-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/uWebSockets/uWebSockets/archive/v${VERSION}.zip"
    FILENAME "uwebsockets-v${VERSION}.zip"
    SHA512 b6389a00a310d77ec55273c1b9499679b13f5e430c31fbc5dd5847780455115d95d5a439cd82dddc537d85c4afb5db4cacefb6db5b3f9681ff142d6ab9ef5024
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
