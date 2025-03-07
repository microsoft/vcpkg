vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  libsdl-org/SDL_ttf
    REF "release-${VERSION}"
    SHA512 98333b3f323a20d5218fc29d217bd4188363a517246b67df86da631463ed19c711f3018e67cdc78565a1ed5913a839d575198dd1a546e98d6a3f68c8f40ef393 
    HEAD_REF main
    PATCHES
        fix-findplutosvg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        harfbuzz SDLTTF_HARFBUZZ
        svg      SDLTTF_PLUTOSVG
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDLTTF_VENDORED=OFF
        -DSDLTTF_SAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(PACKAGE_NAME sdl3_ttf CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME sdl3_ttf CONFIG_PATH lib/cmake/SDL3_ttf)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/sdl3_ttf/SDL3_ttfConfig.cmake"
"# sdl3_ttf cmake project-config input for CMakeLists.txt script"
[[# sdl3_ttf cmake project-config input for CMakeLists.txt script
include(CMakeFindDependencyMacro)
find_dependency(SDL3 CONFIG)]])

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/licenses")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
