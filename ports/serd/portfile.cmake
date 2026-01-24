vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/serd
    REF "v${VERSION}"
    SHA512 2dc168c31edaa2ae496703b5e5f03228b7520079efd0d5ed712629d97524cee8af5ebae754d51bcbecfcbe613b21f1a75eaad0c0f1bfc49b942e7868f7f7f891
    HEAD_REF main
)

if("tools" IN_LIST FEATURES)
    set(tools_option -Dtools=enabled)
else()
    set(tools_option -Dtools=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${tools_option}
)

vcpkg_install_meson()

vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES serdi AUTO_CLEAN)
endif()
vcpkg_fixup_pkgconfig()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
