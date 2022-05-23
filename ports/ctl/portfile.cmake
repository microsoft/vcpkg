vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/inie0722/CTL/archive/refs/tags/v1.0.0.zip"
    FILENAME "v1.0.0.zip"
    SHA512 7f81b524f8d4d8416252b1193b2b2aed16607b771689b2ebc71b620cae82f0228673e8cae3632948c4b62498dd679bd091294965a38fb6f0c50f4bd054d85052
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ctl RENAME copyright)