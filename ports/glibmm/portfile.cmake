# Glib uses winapi functions not available in WindowsStore
string(REGEX MATCH "^([0-9]*[.][0-9]*)" GLIBMM_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(GLIBMM_ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/glibmm/${GLIBMM_MAJOR_MINOR}/glibmm-${VERSION}.tar.xz"
    FILENAME "glibmm-${VERSION}.tar.xz"
    SHA512 bd628bca76570f92c3c0f7cbc878ec74ae243c4f201c205ce0c1fcf8f6778da4ccf72d1a8c712020980278b1a518307cf7c77f16aeb72e0a0816f6bc1d9f2391
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
file(INSTALL "${SOURCE_PATH}/README.win32.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
