# Glib uses winapi functions not available in WindowsStore
string(REGEX MATCH "^([0-9]*[.][0-9]*)" GLIBMM_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(GLIBMM_ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/glibmm/${GLIBMM_MAJOR_MINOR}/glibmm-${VERSION}.tar.xz"
    FILENAME "glibmm-${VERSION}.tar.xz"
    SHA512 af05171b4651e94f4ef0d8e06a27160cd1a7b0a4e596ba7b6584567564829a60031f27ab96a25ba7fefb6395026f4cb40a5eaf1c5bc2e15428c18fd4d52b9328
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
