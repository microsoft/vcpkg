vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gexiv2/0.14/gexiv2-${VERSION}.tar.xz"
    FILENAME "gexiv2-${VERSION}.tar.xz"
    SHA512 24c97fa09b9ee32cb98da4637ea78eb72ae7e2d1792f9ebb31d63e305b3e0e1f6935b8647589c76c39ba631a15c1d8d2f3879c7dff81433786e9533b6348b6a0
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        msvc_def.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dintrospection=false
        -Dvapi=false
        -Dgtk_doc=false
        -Dpython3=false
        -Dtests=false
        -Dtools=false
    ADDITIONAL_BINARIES
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
