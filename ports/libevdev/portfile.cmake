vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libevdev/libevdev
    REF "libevdev-${VERSION}"
    SHA512 9f5496e3a158a41078285741861382b5fb48679b78065e6313b985de8b1832d1a5cb21954e15f4ab69d1c97093c925a51a2263228c5b0d59f3a90a29e374f1d0
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
