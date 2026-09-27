vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO polkit/polkit
    REF "${VERSION}"
    SHA512 3c4fe60618cf6e74467dc0efac084a38c93b0a8e4e8c02d36de5ca35634ecff624b6977b54493e9b1ad41aa87693ac3246e14fe6f6b828f57b2012b869af9105
    HEAD_REF master
    PATCHES
        libs-only-build-polkitagent.patch
)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dauthfw=shadow
        -Dexamples=false
        -Dgtk_doc=false
        -Dintrospection=false
        -Dlibs-only=true
        -Dman=false
        -Dsession_tracking=ConsoleKit
        -Dtests=false
    ADDITIONAL_BINARIES
        "glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'"
        "glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/lib/polkit-1"
    "${CURRENT_PACKAGES_DIR}/lib/polkit-1"
    "${CURRENT_PACKAGES_DIR}/share/dbus-1"
    "${CURRENT_PACKAGES_DIR}/share/gettext"
    "${CURRENT_PACKAGES_DIR}/share/polkit-1"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
