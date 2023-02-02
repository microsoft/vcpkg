# Glib uses winapi functions not available in WindowsStore

vcpkg_download_distfile(GLIBMM_ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/glibmm/2.74/glibmm-2.74.0.tar.xz"
    FILENAME "glibmm-2.74.0.tar.xz"
    SHA512 29c16a6c921fb135721c39b5328e0b45e09c500c65175199c1ec5ee75bdd5fb907072389c6980da3bf8fac0846235af5580f692706eb00d26947804daa1c99c9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${GLIBMM_ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbuild-examples=false
        -Dmsvc14x-parallel-installable=false
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

# intentionally 2.68 - glib does not install glibmm-2.7x files
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/lib/glibmm-2.68/proc"
    "${CURRENT_PACKAGES_DIR}/lib/glibmm-2.68/proc"
)

vcpkg_fixup_pkgconfig()

# Handle copyright and readmes
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME readme.txt)
file(INSTALL "${SOURCE_PATH}/README.SUN" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/README.win32" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
