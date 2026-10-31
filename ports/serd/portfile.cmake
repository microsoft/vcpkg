vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/serd
    REF "v${VERSION}"
    SHA512 8a708065476507d1decc81f7d9586bb928b26cb9394f3e49733947612f284ad28753bab8f7f1eba29b51e3213f90027336ace6fa747b48330cae3d90ef1f9931
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
