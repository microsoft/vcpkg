vcpkg_download_distfile(ARCHIVE
    URLS "https://download.oracle.com/berkeley-db/db-4.8.30.NC.zip"
    FILENAME "db-4.8.30.NC.zip"
    SHA512 59c1d2d5a3551f988ab1dc063900572b67ad087537e0d71760de34601f9ebd4d5c070a49b809bec4a599a62417e9a162683ce0f6442deb1a0dadb80764bf6eab
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES fix-conflict-macro.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
