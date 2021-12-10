vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.gnome.org
    REPO GNOME/libsecret
    REF 0.20.4
    SHA512 b7357329e531ace536ac3c46ef51d022de9308181af227d2ff45c1ff6fe781a29fa93fe02e78f28c84eca8881c2cb90c92c675bcf9fd21b3d326dd84c5692ed5
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dintrospection=false
        -Dgtk_doc=false
        -Dmanpage=false
        -Dvapi=false
    ADDITIONAL_NATIVE_BINARIES
         gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'
         glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# There is no option to disable building secret-tool, so remove the executable.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
