
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.XAudio2.Redist/${VERSION}"
    FILENAME "xaudio2redist.${VERSION}.zip"
    SHA512 2d2a605cda22d2c6e7918d52cb673cb0b4f4e7c2b4b6ee3e1f988431f5cb6f945a17988574e0faca9465fc4370b222e9e8e23215525f3d6b5c276b1e3dc4476e
)

vcpkg_extract_source_archive(
    PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm64|arm64ec")
    set(XAUDIO_ARCH arm64)
else()
    set(XAUDIO_ARCH ${VCPKG_TARGET_ARCHITECTURE})
endif()

file(GLOB HEADER_FILES "${PACKAGE_PATH}/build/native/include/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(INSTALL "${PACKAGE_PATH}/build/native/release/lib/${XAUDIO_ARCH}/xaudio2_9redist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
   file(INSTALL "${PACKAGE_PATH}/build/native/release/lib/${XAUDIO_ARCH}/xapobaseredist_md.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
   set(lib_suffix "_md")
else()
   file(INSTALL "${PACKAGE_PATH}/build/native/release/lib/${XAUDIO_ARCH}/xapobaseredist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
   set(lib_suffix "")
endif()

file(INSTALL "${PACKAGE_PATH}/build/native/release/bin/${XAUDIO_ARCH}/xaudio2_9redist.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

if(NOT DEFINED VCPKG_BUILD_TYPE)
    file(INSTALL "${PACKAGE_PATH}/build/native/debug/lib/${XAUDIO_ARCH}/xaudio2_9redist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        file(INSTALL "${PACKAGE_PATH}/build/native/debug/lib/${XAUDIO_ARCH}/xapobaseredist_md.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    else()
        file(INSTALL "${PACKAGE_PATH}/build/native/debug/lib/${XAUDIO_ARCH}/xapobaseredist.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()

    file(INSTALL "${PACKAGE_PATH}/build/native/debug/bin/${XAUDIO_ARCH}/xaudio2_9redist.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/xaudio2redist-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake"
    @ONLY)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${PACKAGE_PATH}/LICENSE.txt")
