set(VERSION 2.3.3)

if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.steinberg.net/sdk_downloads/asiosdk_2.3.3_2019-06-14.zip"
    FILENAME "asiosdk_2.3.3_2019-06-14.zip"
	SHA512 65d6f2fa4f0e23939fcdf46ff3b04760089c0f14e2ac3e37e63cbf6733f3acc93ab930ea9e3f1eb60483d4654f7ba4699ed506531074c4f55e763ad92736c231
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
file(INSTALL ${SOURCE_PATH}/readme.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/asiosdk)
file(INSTALL ${SOURCE_PATH}/readme.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/asiosdk RENAME copyright)
file(INSTALL ${SOURCE_PATH}/changes.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/asiosdk)
file(INSTALL "${SOURCE_PATH}/Steinberg ASIO Logo Artwork.zip" DESTINATION ${CURRENT_PACKAGES_DIR}/share/asiosdk)
file(INSTALL "${SOURCE_PATH}/Steinberg ASIO Licensing Agreement.pdf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/asiosdk)
file(INSTALL "${SOURCE_PATH}/ASIO SDK 2.3.pdf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/asiosdk)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/Findasiosdk.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

vcpkg_copy_pdbs()
