vcpkg_download_distfile(ARCHIVE
    URLS "https://download.steinberg.net/sdk_downloads/ASIO-SDK_2.3.4_2025-10-15.zip"
    FILENAME "ASIO-SDK_2.3.4_2025-10-15-57de2c0cd0df.zip"
    SHA512 57de2c0cd0df0783275987e08255abfa49da12982f9d462ac40b7f57300c36e024dcb65d100b799fb3c96a9c7c5ee86e61ceb0e68d2839324206c1629d3905ed
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "${VERSION}"
)

file(INSTALL "${SOURCE_PATH}/asio/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/asio")
file(INSTALL "${SOURCE_PATH}/common/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/common")
file(INSTALL "${SOURCE_PATH}/driver/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/driver")
file(INSTALL "${SOURCE_PATH}/host/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}/host")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(
    INSTALL
        "${SOURCE_PATH}/changes.txt"
        "${SOURCE_PATH}/Steinberg ASIO Logo Artwork"
        "${SOURCE_PATH}/Steinberg ASIO Usage Guidelines.pdf"
        "${SOURCE_PATH}/Steinberg ASIO Licensing Agreement.pdf"
        "${SOURCE_PATH}/Steinberg ASIO SDK 2.3.pdf"
        "${SOURCE_PATH}/README.md"
        "${CMAKE_CURRENT_LIST_DIR}/Findasiosdk.cmake"
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
