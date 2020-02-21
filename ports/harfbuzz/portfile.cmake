vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO harfbuzz/harfbuzz
    REF 3a74ee528255cc027d84b204a87b5c25e47bff79 # 2.6.4
    SHA512 4662634546b64dd21cb25ccf47dc56a6274a389cb0801791a34b5088833d033bb665ce10e88d06baefc54cdd471c4107da9bac974382abf1cb4ed991b7e83c7f
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
    icu        HB_HAVE_ICU
    graphite2  HB_HAVE_GRAPHITE2
    ucdn       HB_BUILTIN_UCDN
    glib       HB_HAVE_GLIB
)

# At least one Unicode callback must be specified, or harfbuzz compilation fails
if(NOT ("ucdn" IN_LIST FEATURES OR "glib" IN_LIST FEATURES))
    message(FATAL_ERROR "Error: At least one Unicode callback must be specified (ucdn, glib).")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DHB_HAVE_FREETYPE=ON
        -DHB_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
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

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

