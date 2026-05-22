vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openstack/liberasurecode
    REF "${VERSION}"
    SHA512 22579fdb835e384d14ce305da78e940fda9827f99b1d29da449ec8887a8208eafbee58ffd569af6e639873bdc4e9a1f5a944ebea20cdb8e075f3f10ec7a70202
    HEAD_REF master
    PATCHES
        fix-build.patch
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        "--disable-werror"
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
