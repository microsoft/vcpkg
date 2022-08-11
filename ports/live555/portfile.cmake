vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.live555.com/liveMedia/public/live.2022.07.14.tar.gz"
    FILENAME "live.2022.07.14.tar.gz"
    SHA512 382544d9d9fe200699669a1f3301efb4ccec0193499c95b532ea923c380b1ec6fa721a4118d36a447ba9df08575f185498f244293c66bbe97cff0482eab033c7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    PATCHES
        fix-RTSPClient.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(GLOB HEADERS
    "${SOURCE_PATH}/BasicUsageEnvironment/include/*.h*"
    "${SOURCE_PATH}/groupsock/include/*.h*"
    "${SOURCE_PATH}/liveMedia/include/*.h*"
    "${SOURCE_PATH}/UsageEnvironment/include/*.h*"
)

file(COPY ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
