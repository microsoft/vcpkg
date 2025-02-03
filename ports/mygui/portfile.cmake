vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MyGUI/mygui
    REF MyGUI${VERSION}
    SHA512 88c69ca2e706af364b72d425f95013eb285501881d8094f8d67e31a54c45ca11b0eb5b62c382af0d4c43f69aa8197648259ac306b72efa7ef3e25eecb9b039cb
    HEAD_REF master
    PATCHES
        fix-generation.patch
        Install-tools.patch
        opengl.patch
        sdl2-static.patch
        fix-tools-lnk2005.patch
        platform-lib-static.patch
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
    message(STATUS "Setting MYGUI_RENDERSYSTEM to 8 (GLES) - officially supported MyGUI render system for wasm32")
    set(MYGUI_RENDERSYSTEM 8)
elseif("opengl" IN_LIST FEATURES)
    set(MYGUI_RENDERSYSTEM 4)
else()
    set(MYGUI_RENDERSYSTEM 1)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        plugins MYGUI_BUILD_PLUGINS
        tools MYGUI_BUILD_TOOLS
    INVERTED_FEATURES
        obsolete MYGUI_DONT_USE_OBSOLETE
        plugins MYGUI_DISABLE_PLUGINS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MYGUI_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMYGUI_STATIC=${MYGUI_STATIC}
        -DMYGUI_BUILD_DEMOS=FALSE
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
vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES FontEditor ImageEditor LayoutEditor SkinEditor AUTO_CLEAN)
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
