vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/pango
    REF  3d3f165e77178b630d7dc2b733e64af513c99f5f #v1.50.12
    SHA512 02ddcd0be05d6c8a84f186e6ea5c64019e34922480769f9b8e6e6883dd9d30b7d473681b6dbdf84c5a7e592f0d7bf37984adf2c9b40f37d6207b4bf40bdeaa7b
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
