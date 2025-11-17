vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/sord
    REF "v${VERSION}"
    SHA512 85aef975dedf8428c6ee21f1e53cafa52ee027a36df9395567983de0d0641aff5556866a4807a6a65170c34a4de42cd2a8e4a7b8734cc253f2c14b61a6bab154
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_tools(TOOL_NAMES sordi sord_validate AUTO_CLEAN)
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
