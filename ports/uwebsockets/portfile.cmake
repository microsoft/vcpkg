include(vcpkg_common_functions)
set(VERSION 0.14.4)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/uwebsockets-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/uWebSockets/uWebSockets/archive/v${VERSION}.zip"
    FILENAME "uwebsockets-v${VERSION}.zip"
    SHA512 cc395437790a51a729582897111304e7d6c72574d59c55929a686b6a8a489eb3ea3ea7f037aeda9083243317ed885bd710a708d3dd635220387d3253e0712b10
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
