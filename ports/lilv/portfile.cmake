vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/lilv
    REF "v${VERSION}"
    SHA512 844d72a07d3978e1cc908962f0fb957b47032277a419e1639885e3a49d27278fc48ab774229d18ba2b811bab755c8a1cbfa10b805de5f1cfe1bc2f9424913f5a
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtests=disabled
)

vcpkg_install_meson()
vcpkg_copy_tools(TOOL_NAMES lv2info lv2ls AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
