vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/lilv
    REF "v${VERSION}"
    SHA512 fe0357777de5ecd6314db4496a2c3c0126e82ada3b71f3e1354976785bbe3934126896c855bff8d1d091212c725252a9b7e39bde1413329154ad3e444554f38b
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
    if(VCPKG_TARGET_IS_OSX)
        # Since 0.26.2 lv2bench only builds if the POSIX realtime scheduler 'sched.h' is available, which is not the case on macOS
        vcpkg_copy_tools(TOOL_NAMES lv2apply lv2info lv2ls AUTO_CLEAN)
    else()
        vcpkg_copy_tools(TOOL_NAMES lv2apply lv2bench lv2info lv2ls AUTO_CLEAN)
    endif()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/etc"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
