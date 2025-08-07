set(EXTRA_PATCHES "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    list(APPEND EXTRA_PATCHES fix_clang-cl_build.patch)
endif()

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.freedesktop.org
    REPO cairo/cairo
    REF "${VERSION}"
    SHA512 663e6edf2718e8205e30ba309ac609ced9e88e6e1ec857fc48b345dfce82b044d58ec6b4a2d2b281fba30a659a368625ea7501f8b43fe26c137a7ebffdbaac91
    PATCHES
        msvc-convenience.diff
        ${EXTRA_PATCHES}
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cairo/cairo.h" "defined(CAIRO_WIN32_STATIC_BUILD)" "1")
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/COPYING-LGPL-2.1" "${SOURCE_PATH}/COPYING-MPL-1.1")
