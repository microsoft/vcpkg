vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
string(REPLACE "-" "." format_version ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://live555.com/liveMedia/public/live.${format_version}.tar.gz"
    FILENAME "live.${format_version}.tar.gz"
    SHA512 82b109d1bfbeea386f99527a0887438efb1719f74c76106c44a8b674dfbacd99329d1ddbe8069242a36910810564806fa1d2ec6665f8776f963333d2a7a88837
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
