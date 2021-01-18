
set(VERSION 1.10.2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/graphene/1.10/graphene-${VERSION}.tar.xz"
    FILENAME "graphene-${VERSION}.tar.xz"
    SHA512 a8a8ef1e4ccffee2313a18b9b8dda06c7ede6d49fdde8578694500634e3c90278fd30af7d88938d5ecb08c519cc3e09d21fe69d0f21cb766e056ceedbb3eafb0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dgtk_doc=false
        -Dgobject_types=true
        -Dintrospection=false
        -Dtests=false
        -Dinstalled_tests=false
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES  glib-genmarshal='${CURRENT_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

# option('gtk_doc', type: 'boolean',
       # value: false,
       # description: 'Enable generating the API reference (depends on GTK-Doc)')
# option('gobject_types', type: 'boolean',
       # value: true,
       # description: 'Enable GObject types (depends on GObject)')
# option('introspection', type: 'boolean',
       # value: true,
       # description: 'Enable GObject Introspection (depends on GObject)')
# option('gcc_vector', type: 'boolean',
       # value: true,
       # description: 'Enable GCC vector fast paths (requires GCC)')
# option('sse2', type: 'boolean',
       # value: true,
       # description: 'Enable SSE2 fast paths (requires SSE2 or later)')
# option('arm_neon', type: 'boolean',
       # value: true,
       # description: 'Enable ARM NEON fast paths (requires ARM)')
# option('tests', type: 'boolean',
       # value: true,
       # description: 'Build the test suite (requires GObject)')
# option('installed_tests', type: 'boolean',
       # value: true,
       # description: 'Install tests')

 
