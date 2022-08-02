
set(VERSION 1.10.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/graphene/1.10/graphene-${VERSION}.tar.xz"
    FILENAME "graphene-${VERSION}.tar.xz"
    SHA512 a8a8ef1e4ccffee2313a18b9b8dda06c7ede6d49fdde8578694500634e3c90278fd30af7d88938d5ecb08c519cc3e09d21fe69d0f21cb766e056ceedbb3eafb0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix_clang-cl.patch
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dgtk_doc=false #Enable generating the API reference (depends on GTK-Doc)
        -Dgobject_types=true #Enable GObject types (depends on GObject)
        -Dintrospection=false #Enable GObject Introspection (depends on GObject)'
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

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
