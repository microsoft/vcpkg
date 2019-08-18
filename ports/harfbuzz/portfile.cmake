include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 2.6.0
    SHA512 5a7d455f5f590521cc757487d21c1c92b5379b370410b181a6cbc03685f756fabad8af6cedd79cb82adea0e676e9b6385c2a123cb2e570be5dec2f13f3db3c33
    HEAD_REF master
    PATCHES
        0001-fix-cmake-export.patch
        0002-fix-uwp-build.patch
        0003-remove-broken-test.patch
        # This patch is required for propagating the full list of static dependencies from freetype
        find-package-freetype-2.patch
        # This patch is required for propagating the full list of dependencies from glib
        glib-cmake.patch
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
        -DHB_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

if (HAVE_GLIB)
    # Propagate dependency on glib downstream
    file(READ "${CURRENT_PACKAGES_DIR}/share/harfbuzz/harfbuzzConfig.cmake" _contents)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/harfbuzz/harfbuzzConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(unofficial-glib CONFIG)
    
${_contents}
")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/harfbuzz RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME harfbuzz)
