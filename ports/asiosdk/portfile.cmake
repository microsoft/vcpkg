set(VERSION 2.3.3)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.steinberg.net/sdk_downloads/asiosdk_2.3.3_2019-06-14.zip"
    FILENAME "asiosdk_2.3.3_2019-06-14-eac6c1a57829.zip"
	SHA512 eac6c1a57829b7f722a681c54b2f6469d54695523f08f727d0dd6744dcd7fce4f3249c57689bb15ed7a8bcb912833b226439d800913e122e0ef9ab73672f6542
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    SOURCE_BASE ${VERSION}
)

file(INSTALL ${SOURCE_PATH}/asio/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/asiosdk/asio)
file(INSTALL ${SOURCE_PATH}/common/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/asiosdk/common)
file(INSTALL ${SOURCE_PATH}/driver/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/asiosdk/driver)
file(INSTALL ${SOURCE_PATH}/host/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/asiosdk/host)
file(INSTALL ${SOURCE_PATH}/readme.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/readme.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/changes.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL "${SOURCE_PATH}/Steinberg ASIO Logo Artwork.zip" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL "${SOURCE_PATH}/Steinberg ASIO 2.3.3 Licensing Agreement 2.0.1 - 2019.pdf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL "${SOURCE_PATH}/ASIO SDK 2.3.pdf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/Findasiosdk.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
