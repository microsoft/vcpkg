vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/pango
    REF  26aadb2508f9022cbfc72e73b558c6791f5d46d9 #v1.50.3
    SHA512 09c2578300d391b406c14dfbf7f28968d326c6861f7eb1a3a8d1d8c4700d6e9f74c8621a3f2d181abe1f695324c6e5fc3a55eb038ebbe53a53be086983e3a186
    HEAD_REF master # branch name
) 

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dintrospection=disabled # Build the GObject introspection data for Pango
        -Dfontconfig=enabled # Build with FontConfig support.
        -Dsysprof=disabled # include tracing support for sysprof
        -Dlibthai=disabled # Build with libthai support
        -Dcairo=enabled # Build with cairo support
        -Dxft=disabled # Build with xft support
        -Dfreetype=enabled # Build with freetype support
        -Dgtk_doc=false #Build API reference for Pango using GTK-Doc
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES  glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES pango-view pango-list pango-segmentation AUTO_CLEAN)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/pango.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" [[-I"${includedir}/pango-1.0"]] [[-I"${includedir}/pango-1.0" -I"${includedir}/harfbuzz"]])
endif()
set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/pango.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" [[-I"${includedir}/pango-1.0"]] [[-I"${includedir}/pango-1.0" -I"${includedir}/harfbuzz"]])
endif()
