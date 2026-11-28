vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

string(REPLACE "-" "." format_version "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://download.live555.com/live.${format_version}.tar.gz"
    FILENAME "live.${format_version}.tar.gz"
    SHA512 e347f3170560652d3ed155eaa35e671f4a9f0b68043f366cb87d7a8876175f001a1015a785d22dd8906f0d77257b97314452ff86c478cf75239ad2c11cd25864
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

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/COPYING.LESSER"
)
