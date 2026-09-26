vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libevdev/libevdev
    REF "libevdev-${VERSION}"
    SHA512 2c43c0b2601b84b46fa585ab3fb903e8bb3d4838c3ed2245b6a42b7ecb32f6e2c25211327414d8019994ee29724a1edb06efc7a95480ea0f5cd7589efc515343
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

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
