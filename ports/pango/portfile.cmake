vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/pango
    REF "${VERSION}"
    SHA512 c980cfed2a4811c32ba473846d7d075e0b949a833089f4cafb436ce7442719307a60eb68956606c315dd6185cb8753df87d4bac140d752eaeaf0b67b17afbd79
    HEAD_REF master
) 

if("introspection" IN_LIST FEATURES)
    list(APPEND OPTIONS_RELEASE -Dintrospection=enabled)
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    list(APPEND OPTIONS_RELEASE -Dintrospection=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dfontconfig=enabled # Build with FontConfig support.
        -Dsysprof=disabled # include tracing support for sysprof
        -Dlibthai=disabled # Build with libthai support
        -Dcairo=enabled # Build with cairo support
        -Dxft=disabled # Build with xft support
        -Dfreetype=enabled # Build with freetype support
        -Dgtk_doc=false #Build API reference for Pango using GTK-Doc
        ${OPTIONS}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    OPTIONS_DEBUG
        -Dintrospection=disabled
    ADDITIONAL_BINARIES
        "glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'"
        "glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
)

vcpkg_install_meson(ADD_BIN_TO_PATH)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES pango-view pango-list pango-segmentation AUTO_CLEAN)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
