vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO s-yata/marisa-trie
    REF e54f296bb52d16693931c8b963744931ef1e37f7 #0.2.6
    SHA512 1002c495a7ef3c117c143231a244688529ed6962f1e9b8367087cecca51e2eeea37f61107b54b0a0503119dd90953fd921093799901400a2b5c016ebf6a63f05
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    COPY_SOURCE
    OPTIONS
)

vcpkg_install_make()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
