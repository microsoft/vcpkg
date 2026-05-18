string(REGEX MATCH [[^[1-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 f4ba8660b586a4e738803e4dbfdfcd34fa7ceba9189e7bf3f2b50e21f4d4886f99535ceb3453c89b1d1ae8d96bf4168a135b73b7e1a2dbc46b19e9b710ad56a1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dintrospection=disabled
        -Ddocumentation=disabled
        -Dtests=false
        -Dinstalled_tests=false
        -Dconformance=false
        -Dman=false
        -Dnls=disabled
    ADDITIONAL_BINARIES
        "glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/LGPL-2.1-or-later.txt" "${SOURCE_PATH}/LICENSES/CC0-1.0.txt" "${SOURCE_PATH}/LICENSES/MIT.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tools(
    TOOL_NAMES json-glib-format json-glib-validate
    AUTO_CLEAN
)
