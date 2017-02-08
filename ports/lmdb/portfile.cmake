include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lmdb-LMDB_0.9.18/libraries/liblmdb)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/LMDB/lmdb/archive/LMDB_0.9.18.zip"
    FILENAME "LMDB_0.9.18.zip"
    SHA512 46d7ba226af05443c871f83c6ae0ab2ddbeecd289df59c082e806e135fcaa69d9d9060a19a4a907c4f7046de30871126e91e540eca27fc94446e95ba5616155b
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lmdb-LMDB_0.9.18
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/lmdb_45a88275d2a410e683bae4ef44881e0f55fa3c4d.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake/ DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DLMDB_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/lmdb/lmdb-targets-debug.cmake LMDB_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" LMDB_DEBUG_MODULE "${LMDB_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/lmdb/lmdb-targets-debug.cmake "${LMDB_DEBUG_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/lmdb RENAME copyright)

vcpkg_copy_pdbs()