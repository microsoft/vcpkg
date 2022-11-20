vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO s-yata/marisa-trie
    REF e54f296bb52d16693931c8b963744931ef1e37f7 #0.2.6
    SHA512 0
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(LINKAGE_DYNAMIC yes)
    set(LINKAGE_STATIC no)
else()
    set(LINKAGE_DYNAMIC no)
    set(LINKAGE_STATIC yes)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        "--enable-shared=${LINKAGE_DYNAMIC}"
        "--enable-static=${LINKAGE_STATIC}"
        "--prefix=${CURRENT_INSTALLED_DIR}"
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools")

file(INSTALL "${SOURCE_PATH}/COPYING.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
