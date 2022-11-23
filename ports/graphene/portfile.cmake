vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/graphene/1.10/graphene-${VERSION}.tar.xz"
    FILENAME "graphene-${VERSION}.tar.xz"
    SHA512 c56dab6712cf58387d0512a213cd0cd456679e46a495ee5cfd9bc25440cda2d72d56974af4e462f3c863869a1e2e506b702f468933045609d35fdf006212c67d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix_clang-cl.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgtk_doc=false #Enable generating the API reference (depends on GTK-Doc)
        -Dgobject_types=true #Enable GObject types (depends on GObject)
        -Dintrospection=disabled #Enable GObject Introspection (depends on GObject)'
        -Dtests=false
        -Dinstalled_tests=false
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES  glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
