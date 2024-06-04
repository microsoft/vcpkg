if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(PATCHES fix_clang-cl_build.patch)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://cairographics.org/releases/cairo-${VERSION}.tar.xz"
    FILENAME "cairo-${VERSION}.tar.xz"
    SHA512 6366c7d5e3fd3e12df2edc43aa4ed4c3a517de2ef0b1b3b30dfa8b69a7cae1dd55765801228cec308d2e9792037d0704ae49d95b7b12c06f20df092fa0534e1c
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        cairo_static_fix.patch
        disable-atomic-ops-check.patch # See https://gitlab.freedesktop.org/cairo/cairo/-/issues/554
        fix-static-missing-lib-msimg32.patch
        ${PATCHES}
        fix-alloca-undefine.patch # Upstream PR: https://gitlab.freedesktop.org/cairo/cairo/-/merge_requests/520
        cairo_add_lzo_feature_option.patch
)

if("fontconfig" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dfontconfig=enabled)
else()
    list(APPEND OPTIONS -Dfontconfig=disabled)
endif()

if("freetype" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dfreetype=enabled)
else()
    list(APPEND OPTIONS -Dfreetype=disabled)
endif()

if ("x11" IN_LIST FEATURES)
    message(WARNING "You will need to install Xorg dependencies to use feature x11:\nsudo apt install libx11-dev libxft-dev libxext-dev\n")
    list(APPEND OPTIONS -Dxlib=enabled)
else()
    list(APPEND OPTIONS -Dxlib=disabled)
endif()
list(APPEND OPTIONS -Dxcb=disabled)
list(APPEND OPTIONS -Dxlib-xcb=disabled)

if("gobject" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dglib=enabled)
else()
    list(APPEND OPTIONS -Dglib=disabled)
endif()

if("lzo" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dlzo=enabled)
else()
    list(APPEND OPTIONS -Dlzo=disabled)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{CPP} "cl_cpp_wrapper")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -Dtests=disabled
        -Dzlib=enabled
        -Dpng=enabled
        -Dspectre=auto
        -Dgtk2-utils=disabled
        -Dsymbol-lookup=disabled
)
vcpkg_install_meson()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

set(_file "${CURRENT_PACKAGES_DIR}/include/cairo/cairo.h")
file(READ ${_file} CAIRO_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "!defined(CAIRO_WIN32_STATIC_BUILD)" "0" CAIRO_H "${CAIRO_H}")
else()
    string(REPLACE "!defined(CAIRO_WIN32_STATIC_BUILD)" "1" CAIRO_H "${CAIRO_H}")
endif()
file(WRITE ${_file} "${CAIRO_H}")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

#TODO: Fix script
#set(TOOLS)
#if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/cairo-trace${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
#    list(APPEND TOOLS cairo-trace) # sh script which needs to be fixed due to absolute paths in it.
#endif()
#vcpkg_copy_tools(TOOL_NAMES ${TOOLS} AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/COPYING-LGPL-2.1" "${SOURCE_PATH}/COPYING-MPL-1.1")
