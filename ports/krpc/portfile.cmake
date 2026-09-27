vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/krpc/krpc/releases/download/v${VERSION}/krpc-cpp-${VERSION}.zip"
    FILENAME "krpc-cpp-${VERSION}.zip"
    SHA512 211e1c5435234a016d599608cf3bca4af49903d2c24687c9c18f371a4675923da49dbb53cc74228bd54162ba5e5b037ebf24bb72b8bbceff52b5301af392713e
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
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/krpc")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/COPYING.LESSER"
)
