vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MyGUI/mygui
    REF v${VERSION}
    HEAD_REF master
    SHA512 6bf0430d170a0a6a2afa3724973811025e11bf6622afab8077f4024eea12f4e2835e19b88b46f7a9231ba151445e2a79a8dabee13b6a1e5f6725ac3b880afbeb
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
        -DMYGUI_USE_SYSTEM_PUGIXML=TRUE
        -DMYGUI_RENDERSYSTEM=1
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/MyGUI)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/MYGUI/MyGUI_Platform.h"
        "#ifndef MYGUI_PLATFORM_H_\n#define MYGUI_PLATFORM_H_"
        "#ifndef MYGUI_PLATFORM_H_\n#define MYGUI_PLATFORM_H_\n\n#define MYGUI_STATIC"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
