vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.live555.com/liveMedia/public/live.2022.12.01.tar.gz"
    FILENAME "live.2022.12.01.tar.gz"
    SHA512 bb5dc80b5b1621e04fb8a100bd3deff190efb757da10e6cfc652d6eaa878f6a3e063b2f2219d5d83d6fb6892b55be55eafe2dd43f42a559e1f931130b45584b1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}" 
    PATCHES
        fix-RTSPClient.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-live555)

file(GLOB HEADERS
    "${SOURCE_PATH}/BasicUsageEnvironment/include/*.h*"
    "${SOURCE_PATH}/groupsock/include/*.h*"
    "${SOURCE_PATH}/liveMedia/include/*.h*"
    "${SOURCE_PATH}/UsageEnvironment/include/*.h*"
)

file(COPY ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

