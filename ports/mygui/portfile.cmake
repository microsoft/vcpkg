# MyGUI supports compiling itself as a DLL,
# but it seems platform-related stuff doesn't support dynamic linkage
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MyGUI/mygui
    REF 81e5c67e92920607d16bc2aee1ac32f6fd7d446b #v3.4.1
    SHA512 b13e0a08559b3ddfe42ffcc6cf017fb20d50168785fb551e16f613c60b9ea28a65056a9bc42bdab876368f40dcba1772bc704ad0928c45d8b32e909abc0f1916 
    HEAD_REF master
    PATCHES
        fix-generation.patch
        Use-vcpkg-sdl2.patch
        Install-tools.patch
        fix-osx-build.patch # from https://github.com/MyGUI/mygui/pull/244
)

if("opengl" IN_LIST FEATURES)
    set(MYGUI_RENDERSYSTEM 4)
else()
    set(MYGUI_RENDERSYSTEM 1)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools MYGUI_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMYGUI_STATIC=TRUE
        -DMYGUI_BUILD_DEMOS=FALSE
        -DMYGUI_BUILD_PLUGINS=TRUE
        -DMYGUI_BUILD_UNITTESTS=FALSE
        -DMYGUI_BUILD_TEST_APP=FALSE
        -DMYGUI_BUILD_WRAPPER=FALSE
        -DMYGUI_BUILD_DOCS=FALSE
        -DMYGUI_RENDERSYSTEM=${MYGUI_RENDERSYSTEM}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES FontEditor ImageEditor LayoutEditor SkinEditor AUTO_CLEAN)
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
