vcpkg_download_distfile(ARCHIVE
    URLS "https://download.steinberg.net/sdk_downloads/asiosdk_2.3.3_2019-06-14.zip"
    FILENAME "asiosdk_2.3.3_2019-06-14-d74c0bc09162.zip"
    SHA512 d74c0bc09162640a377aaab2f2ce716f9ee7a6ef8d1aa1aa6bc223a4748c60fa900cc77b1cf6db66f8a4064a074b31a71d75cccc7de3634347865238d9c039af
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/readme.txt")

file(
    INSTALL
        "${SOURCE_PATH}/changes.txt"
        "${SOURCE_PATH}/Steinberg ASIO Logo Artwork.zip"
        "${SOURCE_PATH}/Steinberg ASIO 2.3.3 Licensing Agreement V2.0.3 - 2023.pdf"
        "${SOURCE_PATH}/ASIO SDK 2.3.pdf"
        "${CMAKE_CURRENT_LIST_DIR}/Findasiosdk.cmake"
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
