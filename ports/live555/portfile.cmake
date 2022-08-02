vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.live555.com/liveMedia/public/live.2022.04.26.tar.gz"
    FILENAME "live.2022.04.26.tar.gz"
    SHA512 0226a451129df1d47d10bc96ef2a9ab8ffb0116fd0daac8b16a1dd57b319b9058b587955a01bc4a939c3f64659915815fe182c8c7b02cb286313ff132dcbe144
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
