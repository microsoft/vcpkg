vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(XAUDIO2REDIST_VERSION 1.2.9)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.XAudio2.Redist/${XAUDIO2REDIST_VERSION}"
    FILENAME "xaudio2redist.${XAUDIO2REDIST_VERSION}.zip"
    SHA512 c3b37640fb871523a63cd227653d8d972dd95d6e12ccf2f28c434f51bb77011c821a0cd5ae2a9fa311f005a0083798a3218a98c0a9db5db094a5ef54bb960675
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(GLOB HEADER_FILES "${PACKAGE_PATH}/build/native/include/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(INSTALL "${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
   file(INSTALL "${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist_md.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
   file(INSTALL "${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist_md.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
   file(INSTALL "${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
   file(INSTALL "${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

file(COPY "${PACKAGE_PATH}/build/native/release/bin/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY "${PACKAGE_PATH}/build/native/debug/bin/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

file(INSTALL "${PACKAGE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/xaudio2redist-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" COPYONLY)
