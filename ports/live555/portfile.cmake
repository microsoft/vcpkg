vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://live555.com/liveMedia/public/live.2024.06.26.tar.gz"
    FILENAME "live.2024.06.26.tar.gz"
    SHA512 ece875ed82bb122bb2fb237a5d83b4ae16a2fed0cd3e6c5477a16558545d59898a2acf75293f11c0adf1f57453443e969e22c482ec241e45a61f9048e53c7b44
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix-RTSPClient.patch
        fix_operator_overload.patch
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
