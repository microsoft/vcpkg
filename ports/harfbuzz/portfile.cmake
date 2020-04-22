vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF f9bc373381ddf8553f943b774596ae5a53bf2641# Version 2.6.5
    SHA512 203c16361ec4b6e0ab9a6b87dd9ca5ee72201a8df91595154438d1fcf9e6d0ca03aa80c4fcbdf159828153319a0e36555fd9e34e010c6d17be63512a5368c2b9
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

file(READ ${SOURCE_PATH}/CMakeLists.txt _contents)

if("${_contents}" MATCHES "include \\(FindFreetype\\)")
    message(FATAL_ERROR "Harfbuzz's cmake must not directly include() FindFreetype.")
endif()

if("${_contents}" MATCHES "find_library\\(GLIB_LIBRARIES")
    message(FATAL_ERROR "Harfbuzz's cmake must not directly find_library() glib.")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    icu       HB_HAVE_ICU
    graphite2 HB_HAVE_GRAPHITE2
)

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
    OPTIONS ${FEATURE_OPTIONS}
        -DHB_HAVE_FREETYPE=ON
        -DHB_BUILTIN_UCDN=${BUILTIN_UCDN}
        -DHB_HAVE_GLIB=${HAVE_GLIB}
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
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
