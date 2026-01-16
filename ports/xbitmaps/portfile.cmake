vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO data/bitmaps
    REF  "xbitmaps-${VERSION}"
    SHA512 e9a90555cf38c9c8800f58e1ec92bae3c44cedc491fb6184ad6da575e7fbaf3ee380a3fc2d33072d0ef5f313204588ff9c3668a58726b1251dbb2a4ad362d119
    HEAD_REF master
)

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)
vcpkg_install_make()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/pkgconfig/")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/xbitmaps.pc" "${CURRENT_PACKAGES_DIR}/share/pkgconfig/xbitmaps.pc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage")
