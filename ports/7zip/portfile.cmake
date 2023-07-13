set(7ZIP_VERSION "2201")
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.7-zip.org/a/7z${7ZIP_VERSION}-src.7z"
    FILENAME "7z${7ZIP_VERSION}-src.7z"
    SHA512 c37cede4b7253b8dc4372e9e011ef0fee0c1cd53cf9705bf106672a455e7ce1e5a0a288c763d73d3c28b2a41fb860c9bacb702b01d9192eed810787c7da1e0d8
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
