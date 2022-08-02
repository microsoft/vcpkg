set(7ZIP_VERSION "2200")
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.7-zip.org/a/7z${7ZIP_VERSION}-src.7z"
    FILENAME "7z${7ZIP_VERSION}-src.7z"
    SHA512 ff5bab0ad5c16dee84208b42df27ab1df34499365d934b33f61cd8c79b2a946e8875b1524540c1306381a51d6b24535bbcaf92819bf5331814d6c14cf12d3b07
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/7zip-config.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(
    INSTALL "${SOURCE_PATH}/DOC/License.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
