vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/pango
    REF  eabdbd54ee38fa658be574c4fa4574a05c755f16 #v1.50.11
    SHA512 06077e3cda5f1f5cda1fa37958e981b462715ac119af42e48e78f33807d082c31e903c2e4e753624e5fbf9759f0a66ee1dda055286b11a9e3d8698d5d8dffcb7
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
