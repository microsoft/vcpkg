include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 1.8.4
    SHA512 92742b754713d1df8975d4d8467de04765784d7fd566b7e07e7e7a261b0338e997a5fc11fa4fe282d6d5540d242db40c993812fbc4a881becd95fd3aae598c80
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/0001-fix-uwp-build.patch"
        "${CMAKE_CURRENT_LIST_DIR}/find-package-freetype-2.patch"
        "${CMAKE_CURRENT_LIST_DIR}/glib-cmake.patch"
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
vcpkg_copy_pdbs()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/harfbuzz)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/harfbuzz/COPYING ${CURRENT_PACKAGES_DIR}/share/harfbuzz/copyright)
