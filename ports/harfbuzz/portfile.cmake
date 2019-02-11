include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 2.2.0
    SHA512 5bd3bfa6f4bcfce7f7442876a576529252eeae79af8fe667b20a1c13a0fccc813445e832c85d46e6256ca13aa50e2eb1b81eee98fe9adf63ad3e842dbf2e38cb
    HEAD_REF master
    PATCHES
        0001-fix-cmake-export.patch
)

SET(HB_HAVE_ICU "OFF")
if("icu" IN_LIST FEATURES)
    SET(HB_HAVE_ICU "ON")
endif()

SET(HB_HAVE_GRAPHITE2 "OFF")
if("graphite2" IN_LIST FEATURES)
    SET(HB_HAVE_GRAPHITE2 "ON")
endif()

## Unicode callbacks

# Builtin (UCDN)
set(BUILTIN_UCDN OFF)
if("ucdn" IN_LIST FEATURES)
    set(BUILTIN_UCDN ON)
endif()

# Glib
set(HAVE_GLIB OFF)
if("glib" IN_LIST FEATURES)
    set(HAVE_GLIB ON)
endif()

# At least one Unicode callback must be specified, or harfbuzz compilation fails
if(NOT (BUILTIN_UCDN OR HAVE_GLIB))
    message(FATAL_ERROR "Error: At least one Unicode callback must be specified (ucdn, glib).")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DHB_HAVE_FREETYPE=ON
        -DHB_BUILTIN_UCDN=${BUILTIN_UCDN}
        -DHB_HAVE_ICU=${HB_HAVE_ICU}
        -DHB_HAVE_GLIB=${HAVE_GLIB}
        -DHB_HAVE_GRAPHITE2=${HB_HAVE_GRAPHITE2}
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/harfbuzz TARGET_PATH share/harfbuzz)
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/harfbuzz RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME harfbuzz)
