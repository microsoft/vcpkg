set(VCPKG_POLICY_SKIP_ABSOLUTE_PATHS_CHECK enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/lv2
    REF "v${VERSION}"
    SHA512 d63a223b1e1ab9282392637ea2878cfca5dc466553dcea45fb6d8bc5fe657d0705f01db45affcda29344166fba2738a33da5c15ef44ceec58989e406131e1ded
    HEAD_REF main
    PATCHES
        fix-dll-install.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

