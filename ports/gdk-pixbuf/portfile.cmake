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
    PATCHES
        fix_build.patch
        fix_build_error_windows.patch
)
if(VCPKG_TARGET_IS_WINDOWS)
    #list(APPEND OPTIONS -Dnative_windows_loaders=true) # Use Windows system components to handle BMP, EMF, GIF, ICO, JPEG, TIFF and WMF images, overriding jpeg and tiff.  To build this into gdk-pixbuf, pass in windows" with the other loaders to build in or use "all" with the builtin_loaders option
endif()
vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dman=false                 # Whether to generate man pages (requires xlstproc)
        -Dgtk_doc=false             # Whether to generate the API reference (requires GTK-Doc)
        -Ddocs=false
        -Dpng=true                  # Enable PNG loader (requires libpng)
        -Dtiff=true                 # Enable TIFF loader (requires libtiff), disabled on Windows if "native_windows_loaders" is used
        -Djpeg=true                 # Enable JPEG loader (requires libjpeg), disabled on Windows if "native_windows_loaders" is used
        -Dintrospection=disabled    # Whether to generate the API introspection data (requires GObject-Introspection)
        -Drelocatable=true          # Whether to enable application bundle relocation support
        -Dinstalled_tests=false
        -Dgio_sniffing=false        # Perform file type detection using GIO (Unused on MacOS and Windows)
        -Dbuiltin_loaders=all       # since it is unclear where loadable plugins should be located; 
                                    # Comma-separated list of loaders to build into gdk-pixbuf, or "none", or "all" to build all buildable loaders into gdk-pixbuf
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES  glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        )
vcpkg_install_meson(ADD_BIN_TO_PATH)

# Fix paths in pc file. 
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gdk-pixbuf-2.0.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE [[${bindir}]] "\${bindir}/../../tools/${PORT}" _contents "${_contents}")
    string(REPLACE [[gdk_pixbuf_binarydir=${libdir}/gdk-pixbuf-2.0/2.10.0]] "gdk_pixbuf_binarydir=\${libdir}/../gdk-pixbuf-2.0/2.10.0" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()
set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gdk-pixbuf-2.0.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE [[${bindir}]] "\${bindir}/../tools/${PORT}" _contents "${_contents}")
    string(REPLACE [[gdk_pixbuf_binarydir=${libdir}/gdk-pixbuf-2.0/2.10.0]] "gdk_pixbuf_binarydir=\${libdir}/../gdk-pixbuf-2.0/2.10.0" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

vcpkg_fixup_pkgconfig()

set(TOOL_NAMES gdk-pixbuf-csource gdk-pixbuf-pixdata gdk-pixbuf-query-loaders gdk-pixbuf-thumbnailer)

if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm" AND VCPKG_TARGET_IS_WINDOWS)
    list(REMOVE_ITEM TOOL_NAMES gdk-pixbuf-thumbnailer)
endif()

vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
