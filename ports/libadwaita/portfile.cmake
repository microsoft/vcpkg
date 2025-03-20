vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libadwaita
    REF "${VERSION}"
    SHA512 c16c5916fadf38b85d8f4edf6a788a68c21fb4b89ca36599ec159f00526e4bd24220eff127c76b3be934f5b0166e75155a58b999081b2b09b5ae0bf2ca039fb9
    HEAD_REF main
    PATCHES
)

set(GLIB_TOOLS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/glib")
set(SASSC_TOOLS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/sassc")

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dintrospection=disabled
        -Dtests=false
        -Dgtk_doc=false
        -Dexamples=false
        -Dvapi=false
    ADDITIONAL_BINARIES
        glib-genmarshal='${GLIB_TOOLS_DIR}/glib-genmarshal'
        glib-mkenums='${GLIB_TOOLS_DIR}/glib-mkenums'
        glib-compile-resources='${GLIB_TOOLS_DIR}/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        glib-compile-schemas='${GLIB_TOOLS_DIR}/glib-compile-schemas${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        sassc='${SASSC_TOOLS_DIR}/bin/sassc${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
