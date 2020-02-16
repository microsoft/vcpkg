include(vcpkg_common_functions)

set(7ZIP_VERSION 19.00)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.7-zip.org/a/7z1900-src.7z"
    FILENAME "7z1900-src.7z"
    SHA512 d68b308e175224770adc8b1495f1ba3cf3e7f67168a7355000643d3d32560ae01aa34266f0002395181ed91fb5e682b86e0f79c20625b42d6e2c62dd24a5df93
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${7ZIP_VERSION}
    NO_REMOVE_ONE_LEVEL
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(
    INSTALL ${CMAKE_CURRENT_LIST_DIR}/License.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/7zip
    RENAME copyright
)

vcpkg_test_cmake(PACKAGE_NAME 7zip)
