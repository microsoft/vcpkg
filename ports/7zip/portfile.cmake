set(7ZIP_VERSION "2107")
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.7-zip.org/a/7z${7ZIP_VERSION}-src.7z"
    FILENAME "7z${7ZIP_VERSION}-src.7z"
    SHA512 c13521a9829ac239a89015e1f5da27eeaa2469754e3f8ca32311d964ea9d0b40a17e4f8ccbd425d3e865aa768be345368f1c36f354d5710ac7cb2749dd6a3ab5
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
