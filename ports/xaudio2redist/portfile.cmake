vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.XAudio2.Redist/${VERSION}"
    FILENAME "xaudio2redist.${VERSION}.zip"
    SHA512 5eae9c94710ba6e51045e6f9dbe381bdfe76184a4272f561976582e8f585ef8343df9f6eaa2d391bfda06796000bc13ccb0f5bf112d7f2c7865f75ab0e89ab56
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

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
   file(INSTALL "${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist_md.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
   file(INSTALL "${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist_md.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
   set(lib_suffix "_md")
else()
   file(INSTALL "${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
   file(INSTALL "${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
   set(lib_suffix "")
endif()

file(COPY "${PACKAGE_PATH}/build/native/release/bin/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY "${PACKAGE_PATH}/build/native/debug/bin/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

file(INSTALL "${PACKAGE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

configure_file("${CMAKE_CURRENT_LIST_DIR}/xaudio2redist-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" @ONLY)
