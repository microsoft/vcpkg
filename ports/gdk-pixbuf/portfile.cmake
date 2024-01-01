vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/gdk-pixbuf
    REF "${VERSION}"
    SHA512 5b7ddb6e816a88ffd2b7f85583c841ea92719bef7da1acbd6f5714afebf8538660c5d391809f959eb1887613f9579cf51c85d6796c84335cedbf7af975d790c9
    HEAD_REF master
    PATCHES
        fix_build_error_windows.patch
        loaders-cache.patch
        use-libtiff-4-pkgconfig.patch
)

if("introspection" IN_LIST FEATURES)
    list(APPEND OPTIONS_DEBUG -Dintrospection=disabled)
    list(APPEND OPTIONS_RELEASE -Dintrospection=enabled)
else()
    list(APPEND OPTIONS -Dintrospection=disabled)
endif()

if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(GIR_TOOL_DIR ${CURRENT_INSTALLED_DIR})
else()
    set(GIR_TOOL_DIR ${CURRENT_HOST_INSTALLED_DIR})
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
        -Dpng=enabled               # Enable PNG loader (requires libpng)
        -Dtiff=enabled              # Enable TIFF loader (requires libtiff), disabled on Windows if "native_windows_loaders" is used
        -Djpeg=enabled              # Enable JPEG loader (requires libjpeg), disabled on Windows if "native_windows_loaders" is used
        -Drelocatable=true          # Whether to enable application bundle relocation support
        -Dtests=false
        -Dinstalled_tests=false
        -Dgio_sniffing=false        # Perform file type detection using GIO (Unused on MacOS and Windows)
        -Dbuiltin_loaders=all       # since it is unclear where loadable plugins should be located;
                                    # Comma-separated list of loaders to build into gdk-pixbuf, or "none", or "all" to build all buildable loaders into gdk-pixbuf
        ${OPTIONS}
    OPTIONS_DEBUG
        ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    ADDITIONAL_BINARIES
        glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources'
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-scanner='${GIR_TOOL_DIR}/tools/gobject-introspection/g-ir-scanner'
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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
