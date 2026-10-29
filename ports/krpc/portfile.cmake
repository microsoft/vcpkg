vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/krpc/krpc/releases/download/v${VERSION}/krpc-cpp-${VERSION}.zip"
    FILENAME "krpc-cpp-${VERSION}.zip"
    SHA512 6cd7a50b52f09aee507ecbf028d92b0d265b2544f636b419cc0a358b060acc4f15826d4cfc8f676d646e91f15178ecfe7fbd46c21b00059023287952f3c1c1a4
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "krpc-cpp-${VERSION}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKRPC_FETCH_PROTOBUF=OFF
        -DKRPC_FETCH_ASIO=OFF
        -DKRPC_FETCH_ABSL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/krpc)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/COPYING.LESSER"
)
