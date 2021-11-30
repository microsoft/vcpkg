
set(7ZIP_VERSION 21.06)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.7-zip.org/a/7z2106-src.7z"
    FILENAME "7z2106-src.7z"
    SHA512 2ad05eaf14770584d7e6111734c7c239ab0163f9fd9b0cc5473fa33d5c882b0493331dd0f851af5e8be2b7d1eaede2f96f30f8e777b05d17c46a0121ff8211ec 
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${7ZIP_VERSION}
    NO_REMOVE_ONE_LEVEL
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/License.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
