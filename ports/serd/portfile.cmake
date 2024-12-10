vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/serd
    REF "v${VERSION}"
    SHA512 f90bf597579c5f858ebfe19a7e7cb0b824fe7485c475e3cce88427dd99f9228f5bf4708b7a9f2c67763a3c76166043cdc8cfc2d4891fab6d2a85d6ae8cd97615
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_tools(TOOL_NAMES serdi AUTO_CLEAN)
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
