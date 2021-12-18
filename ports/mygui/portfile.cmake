# MyGUI supports compiling itself as a DLL,
# but it seems platform-related stuff doesn't support dynamic linkage
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MyGUI/mygui
    REF 26109822f36a4f7d72d5d8ecd41659897f085a40
    SHA512 4d1f001e8c04d08ad911bc0345a2287b5e17e21284728cf23d7a930e8befb2f85902053e3c90283444bf9e32c7dada2f37c498e735d6314732b297d97ed339e4
    HEAD_REF master
    PATCHES
        fix-generation.patch
)

if("opengl" IN_LIST FEATURES)
    set(MYGUI_RENDERSYSTEM 4)
else()
    set(MYGUI_RENDERSYSTEM 1)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMYGUI_STATIC=TRUE
        -DMYGUI_BUILD_DEMOS=FALSE
        -DMYGUI_BUILD_PLUGINS=TRUE
        -DMYGUI_BUILD_TOOLS=FALSE
        -DMYGUI_BUILD_UNITTESTS=FALSE
        -DMYGUI_BUILD_TEST_APP=FALSE
        -DMYGUI_BUILD_WRAPPER=FALSE
        -DMYGUI_BUILD_DOCS=FALSE
        -DMYGUI_RENDERSYSTEM=${MYGUI_RENDERSYSTEM}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING.MIT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
