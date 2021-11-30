vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/pango
    REF  dc5bde2a20cbb025c9d0ed29ed687740a4d027da #v1.48.10
    SHA512 8454b2cb81fd57e140372b5c1e5786542e92bcad85d4718b7976dccbf694cfe0fec62938edc32e5de50991e2cda2b00e8d4e976921881069ca29976fe973f4ac
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
