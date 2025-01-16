vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openstack/liberasurecode
    REF "${VERSION}"
    SHA512 9815e159e6b9aa44e47fb0ec1eec04321c48e160ec617511720569e445d8085848124e7385ab2be54615e0c2f4a37a44ae5d2de460a7d6ea36782dfe08c2e53a
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
