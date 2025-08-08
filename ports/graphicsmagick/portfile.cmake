string(REPLACE "." "_" graphicsmagick_version "GraphicsMagick-${VERSION}")

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://foss.heptapod.net/
    REPO graphicsmagick/graphicsmagick
    REF ${graphicsmagick_version}
    SHA512 e64842dbbe2026e7d75b4004f615f32b4e2d57ce8dbd9bc90f87ee6e180d7e2feb61da6c25d404c43ac8d7661f94f7be3bd2882928dbd0e276b5c9040690f6f4
    PATCHES
        # GM always requires a dynamic BZIP2. This patch makes this dependent if _DLL is defined
        dynamic_bzip2.patch

        # Bake GM's own modules into the .dll itself.  This fixes a bug whereby
        # 'vcpkg install graphicsmagick' did not lead to a copy of GM that could
        # load either PNG or JPEG files (due to missing GM Modules, with names
        # matching "IM_*.DLL").
        disable_graphicsmagick_modules.patch
        fix-png.patch
        dirnet.patch
)

configure_file ("${CMAKE_CURRENT_LIST_DIR}/magick_types.h" "${SOURCE_PATH}/magick/magick_types.h.in" COPYONLY)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        VERBOSE=yes
)

vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# copy config
file(COPY "${SOURCE_PATH}/config/colors.mgk" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/config")
file(COPY "${SOURCE_PATH}/config/log.mgk" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/config")
file(COPY "${SOURCE_PATH}/config/modules.mgk" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/config")

file(READ "${SOURCE_PATH}/config/type-windows.mgk.in" TYPE_MGK)
string(REPLACE "@windows_font_dir@" "$ENV{SYSTEMROOT}/Fonts/" TYPE_MGK "${TYPE_MGK}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/graphicsmagick/config/type.mgk" "${TYPE_MGK}")

configure_file("${SOURCE_PATH}/config/delegates.mgk.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/config/delegates.mgk" @ONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(FILE_LIST
        "GraphicsMagick++-config"
        "GraphicsMagick-config"
        "GraphicsMagickWand-config"
)
foreach(filename ${FILE_LIST})
    
    set(file "${CURRENT_PACKAGES_DIR}/tools/graphicsmagick/bin/${filename}")
    vcpkg_replace_string("${file}" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../.." IGNORE_UNCHANGED)
    if(NOT VCPKG_BUILD_TYPE)
        set(debug_file "${CURRENT_PACKAGES_DIR}/tools/graphicsmagick/debug/bin/${filename}")
        vcpkg_replace_string("${debug_file}" "${CURRENT_INSTALLED_DIR}/debug" "`dirname $0`/../../../../debug" IGNORE_UNCHANGED)
        vcpkg_replace_string("${debug_file}" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../../debug" IGNORE_UNCHANGED)
    endif()
endforeach()

# copy license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright.txt")
