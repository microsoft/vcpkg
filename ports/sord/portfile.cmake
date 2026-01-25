vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/sord
    REF "v${VERSION}"
    SHA512 dec91f193ae6e97453cf6a33fab396eebb4f68014c57c150813f1b93e61157ba32f13ac00e026186639a9c4f7fdfbd58e9e5353f8cee14c0dbe3d19cdde7c22e
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
