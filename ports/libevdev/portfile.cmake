vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libevdev/libevdev
    REF "libevdev-${VERSION}"
    SHA512 4e3d81af35151b965410dd382482c0971b138c2432dd6c86fc843c4c5f697c36d0c30914f11575ca85d5e5f8c79cc27f2a2cdabe3ba04b8e28aa80ecf17bdfef
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddocumentation=disabled
        -Dtools=disabled
        -Dtests=disabled
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
