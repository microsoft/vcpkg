vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.XAudio2.Redist/1.2.8"
    FILENAME "xaudio2redist.1.2.8.zip"
    SHA512 509b2783457b86ed1878fd4e14a01fa7288591925a2bb3cad4d68afd597fbff1f1349b619dad628b5d685169825a775120e1611559e9097837cff0fb6d39acf0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH PACKAGE_PATH
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/Findxaudio2redist.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
