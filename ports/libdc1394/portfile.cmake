set(LIBDC1394_VER "2.2.6")

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libdc1394/libdc1394-2
    REF "${LIBDC1394_VER}"
    FILENAME "libdc1394-${LIBDC1394_VER}.tar.gz"
    SHA512 2d60ed1054da67d8518e870193b60c1d79778858f48cc6487e252de00cc57a08548515d41914a37d0227d29e158d68892c290f83930ffd95f4a483dce5aa3d25
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "--disable-examples"
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
