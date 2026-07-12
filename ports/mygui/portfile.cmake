vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MyGUI/mygui
    REF v${VERSION}
    SHA512 6bf0430d170a0a6a2afa3724973811025e11bf6622afab8077f4024eea12f4e2835e19b88b46f7a9231ba151445e2a79a8dabee13b6a1e5f6725ac3b880afbeb
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
        tools MYGUI_BUILD_TOOLS
        msdf MYGUI_MSDF_FONTS
        msdf MYGUI_USE_SYSTEM_MSDFGEN
    INVERTED_FEATURES
        obsolete MYGUI_DONT_USE_OBSOLETE
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
        -DMYGUI_USE_SYSTEM_PUGIXML=TRUE
        -DMYGUI_RENDERSYSTEM=${MYGUI_RENDERSYSTEM}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/MyGUI)

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
