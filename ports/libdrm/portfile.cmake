vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesa/drm
    REF libdrm-${VERSION}
    SHA512 8a15f194c223f8c0f011bb9b0fa6b2ce8a2e0101cad3a6b27a62de7727f42098d0f4af156b058a254f8d9e189dec18c427cad2a7bee140d7a61c42828a1d1571
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dcairo-tests=disabled
        -Dman-pages=disabled
        -Dtests=false
        -Dvalgrind=disabled
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_list(SET copyright_files
    "${CURRENT_PORT_DIR}/copyright/MIT-style"
    "${CURRENT_PORT_DIR}/copyright/uthash.h"
)
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/libdrm/etnaviv_drmif.h")
    vcpkg_list(APPEND copyright_files "${CURRENT_PORT_DIR}/copyright/etnaviv_drm.h")
endif()

vcpkg_install_copyright(FILE_LIST ${copyright_files} COMMENT [[
Most source files are under similar MIT-style license terms, summarized
in a single section below. Refer to the individual source files for the
official terms.
Some source files are under other license terms, listed in separate sections.
]])
