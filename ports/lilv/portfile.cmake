vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/lilv
    REF "v${VERSION}"
    SHA512 add394bdf6453c9e33e73c2ffe3074f0fddfb067351ff6f0242d1ce5219c212398531c979d952a48c14a13efb3114d4314b553e20689435626b36af8a3c8c56c
    HEAD_REF master
)

set(options "")
if("tools" IN_LIST FEATURES)
    list(APPEND options -Dtools=enabled)
else()
    list(APPEND options -Dtools=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -Dbindings_cpp=enabled
        -Dbindings_py=disabled
        -Ddocs=disabled
        -Dtests=disabled
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES lv2apply lv2bench lv2info lv2ls AUTO_CLEAN)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
