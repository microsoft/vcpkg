vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openstack/liberasurecode
    REF "${VERSION}"
    SHA512 52b94a0fd211721c43f1d4f3c67331aaf8670d178366eef08a1037738935764897d91453d27b9fd69e9a5235f9ed1d11585ed29278887a82907fb30f960423cd
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
