set(GDK_PIXBUF_VERSION 2.42)
set(GDK_PIXBUF_PATCH 9)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/gdk-pixbuf
    REF "${GDK_PIXBUF_VERSION}.${GDK_PIXBUF_PATCH}"
    SHA512 3406f47b413fe3860df410a0cc0076ce47d10605b39347105690c85616739e67e5dfd0804efcad758614b0c8d1369e410b9efaa704a234bfd19686b82595b9e1
    HEAD_REF master
    PATCHES
        fix_build_error_windows.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    #list(APPEND OPTIONS -Dnative_windows_loaders=true) # Use Windows system components to handle BMP, EMF, GIF, ICO, JPEG, TIFF and WMF images, overriding jpeg and tiff.  To build this into gdk-pixbuf, pass in windows" with the other loaders to build in or use "all" with the builtin_loaders option
endif()
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dman=false                 # Whether to generate man pages (requires xlstproc)
        -Dgtk_doc=false             # Whether to generate the API reference (requires GTK-Doc)
        -Ddocs=false
        -Dpng=enabled               # Enable PNG loader (requires libpng)
        -Dtiff=enabled              # Enable TIFF loader (requires libtiff), disabled on Windows if "native_windows_loaders" is used
        -Djpeg=enabled              # Enable JPEG loader (requires libjpeg), disabled on Windows if "native_windows_loaders" is used
        -Dintrospection=disabled    # Whether to generate the API introspection data (requires GObject-Introspection)
        -Drelocatable=true          # Whether to enable application bundle relocation support
        -Dtests=false
        -Dinstalled_tests=false
        -Dgio_sniffing=false        # Perform file type detection using GIO (Unused on MacOS and Windows)
        -Dbuiltin_loaders=all       # since it is unclear where loadable plugins should be located;
                                    # Comma-separated list of loaders to build into gdk-pixbuf, or "none", or "all" to build all buildable loaders into gdk-pixbuf
    ADDITIONAL_NATIVE_BINARIES glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources'
                               glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES  glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources'
                               glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        )
vcpkg_install_meson(ADD_BIN_TO_PATH)

# Fix paths in pc file.
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gdk-pixbuf-2.0.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE [[${bindir}]] "\${prefix}/../tools/${PORT}" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()
set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gdk-pixbuf-2.0.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE [[${bindir}]] "\${prefix}/tools/${PORT}" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

vcpkg_fixup_pkgconfig()

set(TOOL_NAMES gdk-pixbuf-csource gdk-pixbuf-pixdata gdk-pixbuf-query-loaders gdk-pixbuf-thumbnailer)

# gdk-pixbuf-thumbnailer is not compiled for cross-compiling 
set(IS_NEED_REMOVE_THUMBNAILER ${VCPKG_CROSSCOMPILING})
# This adjusting logic might be place in vcpkg_common_definitions.cmake.
if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "(x|X)86" OR VCPKG_TARGET_ARCHITECTURE MATCHES "(amd|AMD|x|X)64")
        set(IS_NEED_REMOVE_THUMBNAILER false)
    endif()
endif()
if(IS_NEED_REMOVE_THUMBNAILER)
    list(REMOVE_ITEM TOOL_NAMES gdk-pixbuf-thumbnailer)
endif()

vcpkg_copy_pdbs()
vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
