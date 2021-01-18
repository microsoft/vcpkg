set(GDK_PIXBUF_VERSION 2.42)
set(GDK_PIXBUF_PATCH 2)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/gdk-pixbuf/${GDK_PIXBUF_VERSION}/gdk-pixbuf-${GDK_PIXBUF_VERSION}.${GDK_PIXBUF_PATCH}.tar.xz"
    FILENAME "gdk-pixbuf-${GDK_PIXBUF_VERSION}.${GDK_PIXBUF_PATCH}.tar.xz"
    SHA512 f341d032ea410efed7a35f8ca6a7389bf988f663dae16e774d114d6f11611e9e182c835e90d752b71c258c905cc5c4c785ea697feed5e6921a2a676c9deaa5f2
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)
if(VCPKG_TARGET_IS_WINDOWS)
    #list(APPEND OPTIONS -Dnative_windows_loaders=true)
endif()
vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dman=false
        -Dgtk_doc=false
        -Ddocs=false
        -Dpng=true
        -Dtiff=true
        -Djpeg=true
        -Dintrospection=disabled
        -Drelocatable=true
        -Dinstalled_tests=false
        -Dgio_sniffing=false
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES  glib-genmarshal='${CURRENT_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_INSTALLED_DIR}/tools/glib/glib-mkenums'
        )
vcpkg_install_meson(ADD_BIN_TO_PATH)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES gdk-pixbuf-csource gdk-pixbuf-pixdata gdk-pixbuf-query-loaders gdk-pixbuf-thumbnailer AUTO_CLEAN)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gdk-pixbuf)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gdk-pixbuf/COPYING ${CURRENT_PACKAGES_DIR}/share/gdk-pixbuf/copyright)

# option('png',
       # description: 'Enable PNG loader (requires libpng)',
       # type: 'boolean',
       # value: true)
# option('tiff',
       # description: 'Enable TIFF loader (requires libtiff), disabled on Windows if "native_windows_loaders" is used',
       # type: 'boolean',
       # value: true)
# option('jpeg',
       # description: 'Enable JPEG loader (requires libjpeg), disabled on Windows if "native_windows_loaders" is used',
       # type: 'boolean',
       # value: true)
# option('builtin_loaders',
       # description: 'Comma-separated list of loaders to build into gdk-pixbuf, or "none", or "all" to build all buildable loaders into gdk-pixbuf',
       # type: 'string',
       # value: 'none')
# option('gtk_doc',
       # description: 'Whether to generate the API reference (requires GTK-Doc)',
       # type: 'boolean',
       # value: false)
# option('docs',
       # description: 'Whether to generate the whole documentation (see: gtk_doc and man options) [Deprecated]',
       # type: 'boolean',
       # value: false)
# option('introspection',
       # description: 'Whether to generate the API introspection data (requires GObject-Introspection)',
       # type: 'feature',
       # value: 'auto',
       # yield: true)
# option('man',
       # description: 'Whether to generate man pages (requires xlstproc)',
       # type: 'boolean',
       # value: true)
# option('relocatable',
       # description: 'Whether to enable application bundle relocation support',
       # type: 'boolean',
       # value: false)
# option('native_windows_loaders',
       # description: 'Use Windows system components to handle BMP, EMF, GIF, ICO, JPEG, TIFF and WMF images, overriding jpeg and tiff.  To build this into gdk-pixbuf, pass in windows" with the other loaders to build in or use "all" with the builtin_loaders option',
       # type: 'boolean',
       # value: false)
# option('installed_tests',
       # description: 'Install the test suite',
       # type: 'boolean',
       # value: true)
# option('gio_sniffing',
       # description: 'Perform file type detection using GIO (Unused on MacOS and Windows)',
       # type: 'boolean',
       # value: true)
