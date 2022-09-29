
# vcpkg_from_github(
#     OUT_SOURCE_PATH SOURCE_PATH
#     REPO xapian/xapian
#     REF ac70c200019231fd00beeba6908b558dfa4ec62f
#     SHA512 7cabd69f1ea4a978a3f5248b6730cea5b9cd833d26b125823369b2013a7a38331cafe6e038998166aed28ea8944a0f8d83d9d8c3432c919b1093852a86a28563
#     HEAD_REF master
# )
vcpkg_download_distfile(ARCHIVE
    URLS https://oligarchy.co.uk/xapian/1.4.21/xapian-core-1.4.21.tar.xz
    FILENAME xapian-core-1.4.21.tar.xz
    SHA512 4071791daf47f5ae77f32f358c6020fcfa9aa81c15c8da25489b055eef30383695e449ab1cb73670f2f5db2b2a5f78056da0e8eea89d83aaad91dfe340a6b13a
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)
if(WIN32)
vcpkg_replace_string("${SOURCE_PATH}/configure.ac"
"z zlib zdll" "z zlib zdll zlibd"
)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
vcpkg_fixup_pkgconfig()
# vcpkg_cmake_config_fixup()
# vcpkg_copy_pdbs()
