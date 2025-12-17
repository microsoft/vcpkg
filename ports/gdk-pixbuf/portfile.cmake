string(REGEX MATCH [[^[0-9][0-9]*\.[1-9][0-9]*]] VERSION_MAJOR_MINOR ${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS
        "https://download.gnome.org/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "GNOME-${PORT}-${VERSION}.tar.xz"
    SHA512 ae9fcc9b4e8fd10a4c9bf34c3a755205dae7bbfe13fbc93ec4e63323dad10cc862df6a9e2e2e63c84ffa01c5e120a3be06ac9fad2a7c5e58d3dc6ba14d1766e8
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix_build_error_windows.patch
        loaders-cache.patch
        use-libtiff-4-pkgconfig.patch
        fix-static-deps.patch
)

if("introspection" IN_LIST FEATURES)
    list(APPEND OPTIONS_RELEASE -Dintrospection=enabled)
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    list(APPEND OPTIONS_RELEASE -Dintrospection=disabled)
endif()

if("png" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dpng=enabled)
else()
    list(APPEND OPTIONS -Dpng=disabled)
endif()

if("tiff" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dtiff=enabled)
else()
    list(APPEND OPTIONS -Dtiff=disabled)
endif()

if("jpeg" IN_LIST FEATURES)
    list(APPEND OPTIONS -Djpeg=enabled)
else()
    list(APPEND OPTIONS -Djpeg=disabled)
endif()

if("others" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dothers=enabled)
else()
    list(APPEND OPTIONS -Dothers=disabled)
endif()

# Whether to enable application bundle relocation support.
# Limitation cf. gdk-pixbuf/gdk-pixbuf-io.c
if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -Drelocatable=true)          
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    #list(APPEND OPTIONS -Dnative_windows_loaders=true) # Use Windows system components to handle BMP, EMF, GIF, ICO, JPEG, TIFF and WMF images, overriding jpeg and tiff.  To build this into gdk-pixbuf, pass in windows" with the other loaders to build in or use "all" with the builtin_loaders option
endif()
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dman=false                 # Whether to generate man pages (requires xlstproc)
        -Dgtk_doc=false             # Whether to generate the API reference (requires GTK-Doc)
        -Ddocs=false
        -Dtests=false
        -Dinstalled_tests=false
        -Dgio_sniffing=false        # Perform file type detection using GIO (Unused on MacOS and Windows)
        -Dbuiltin_loaders=all       # since it is unclear where loadable plugins should be located;
                                    # Comma-separated list of loaders to build into gdk-pixbuf, or "none", or "all" to build all buildable loaders into gdk-pixbuf
        ${OPTIONS}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    OPTIONS_DEBUG
        -Dintrospection=disabled
    ADDITIONAL_BINARIES
        glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources'
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
)
vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gdk-pixbuf-2.0.pc" [[${bindir}]] "\${prefix}/tools/${PORT}")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gdk-pixbuf-2.0.pc" [[${bindir}]] "\${prefix}/../tools/${PORT}")
endif()
vcpkg_fixup_pkgconfig()

set(TOOL_NAMES gdk-pixbuf-csource gdk-pixbuf-pixdata gdk-pixbuf-query-loaders)
# gdk-pixbuf-thumbnailer is not compiled for cross-compiling
# vcpkg-meson cross-build configuration differs from VCPKG_CROSSCOMPILING
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/gdk-pixbuf-thumbnailer${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    list(APPEND TOOL_NAMES gdk-pixbuf-thumbnailer)
endif()
vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
