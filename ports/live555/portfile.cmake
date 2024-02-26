vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://live555.com/liveMedia/public/live.2023.11.30.tar.gz"
    FILENAME "live.2023.11.30.tar.gz"
    SHA512 c91703197448f65d63a8a6e07597791da1ee63d3b59a0809454468a3869d86e21533c7fc434d0178a179d5a2e0e5614539e47daad813fbbe7468028419026892
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
