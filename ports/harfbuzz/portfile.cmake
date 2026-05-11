vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF ${VERSION}
    SHA512 649521b69d5d7328245cabca8b769448f695b0b7e3bf16208ddb1635b29165dfd363a06b1b2831229f6ff722d0e8212fd82054e6b64992552a6a21af238c5cb3
    HEAD_REF master
    PATCHES
        fix-eol-mismatch.diff # https://github.com/harfbuzz/harfbuzz/commit/ab6aa4f449457be45e8e0218f7a8de271fb19967.diff?full_index=1
        ${ANDROID_LOCALECONV_L_PATCH}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "cairo"             HB_HAVE_CAIRO
    "coretext"          HB_HAVE_CORETEXT
    "directwrite"       HB_HAVE_DIRECTWRITE
    "freetype"          HB_HAVE_FREETYPE
    "gdi"               HB_HAVE_GDI
    "glib"              HB_HAVE_GLIB
    "glib"              HB_HAVE_GOBJECT
    "gpu"               HB_BUILD_GPU
    "graphite2"         HB_HAVE_GRAPHITE2
    "icu"               HB_HAVE_ICU
    "introspection"     HB_HAVE_INTROSPECTION
    "tools"             HB_BUILD_UTILS
    "tools"             HB_BUILD_SUBSET
    "tools"             HB_BUILD_RASTER
    "tools"             HB_BUILD_VECTOR
    "raster"            HB_BUILD_RASTER
    "vector"            HB_BUILD_VECTOR
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
vcpkg_fixup_pkgconfig()

# vcpkg_list(SET TOOL_NAMES)
# if("glib" IN_LIST FEATURES)
#     vcpkg_list(APPEND TOOL_NAMES hb-subset hb-shape hb-info hb-vector hb-raster)
#     if("cairo" IN_LIST FEATURES)
#         vcpkg_list(APPEND TOOL_NAMES hb-view)
#     endif()
# endif()
# if(TOOL_NAMES)
#     vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
# endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
