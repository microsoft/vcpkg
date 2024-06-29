vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openstack/liberasurecode
    REF "${VERSION}"
    SHA512 d5daa962324ef19fd195cfa842ec375d9dd5e62e3391b4a1cbf49a850b852b18cfc9be929ab18786d6b839139f6260d5cb4c88a0ba440c06b0e54e04ffb1bee1
    HEAD_REF master
    PATCHES
        fix-build.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        "--disable-werror"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
