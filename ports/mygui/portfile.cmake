vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MyGUI/mygui
    REF v${VERSION}
    HEAD_REF master
    SHA512 6deaf4496f956d1ac02db662818a66c5d199cf05ae1da1f04f1a9ab7ea309a58436d37098c3205a635744ef6502afb505c3c7f49d34082736275c41493d9deb6
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        msdf MYGUI_MSDF_FONTS
        msdf MYGUI_USE_SYSTEM_MSDFGEN
    INVERTED_FEATURES
        obsolete MYGUI_DONT_USE_OBSOLETE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMYGUI_BUILD_DEMOS=FALSE
        -DMYGUI_BUILD_UNITTESTS=FALSE
        -DMYGUI_BUILD_TEST_APP=FALSE
        -DMYGUI_BUILD_WRAPPER=FALSE
        -DMYGUI_BUILD_DOCS=FALSE
        -DMYGUI_BUILD_TOOLS=FALSE
        -DMYGUI_BUILD_ADVANCED_DEMOS=FALSE
        -DMYGUI_USE_SYSTEM_PUGIXML=TRUE
        -DMYGUI_USE_SYSTEM_UTF8CPP=TRUE
        -DMYGUI_RENDERSYSTEM=1 # Use an overlay port to change the render system. Read the discussion at: https://github.com/microsoft/vcpkg/pull/52862
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

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
