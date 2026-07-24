string(REPLACE "-" "." format_version ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://download.live555.com/live.${format_version}.tar.gz"
    FILENAME "live.${format_version}.tar.gz"
    SHA512 153649c7c4a63da6f9c5ec083b7897d70f4778d8872804f4e76f949f3b8ed750efd628d2f2cf38e326a4f6f67fe1eb6cd9153e150318efbf9ccf689bde076394
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
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
