vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO drobilla/serd
    REF "v${VERSION}"
    SHA512 ff2dcdff0431d2a484bb205ff3d1740ad83fd87233bd09a558c7752ecbd26431998a4fc498f99584bc0db37c666a63fc60b9f49a56ed0241a1c96c47e5451a8b
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
