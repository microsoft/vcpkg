vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "Linux" "OSX" "uwp")

set(VERSION 2.3.3)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.steinberg.net/sdk_downloads/asiosdk_2.3.3_2019-06-14.zip"
    FILENAME "asiosdk_2.3.3_2019-06-14-eac6c1a5.zip"
	SHA512 f73973067502a6d1696372eac57707984d6df57fe0cfc47f74ea73e401f0258c63f72ff9b5a161f61df551c0f1cb3f82d1ea4e8e3e301debc9dcab4c069f07f5
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
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
