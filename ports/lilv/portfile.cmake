vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/lilv
    REF "v${VERSION}"
    SHA512 4b39766a3340e545e2d30af19fcd5916a3231f9144c8da76bf47eda4d1c73bbdbb23f15a7f52610096daa54ef752d034b4fab340014a54fb5ab9057f592ed278
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
