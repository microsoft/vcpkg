set(PATCHES
    fix-generation.patch
    sdl2-static.patch
)

if("tools" IN_LIST FEATURES)
  list(APPEND PATCHES Install-tools.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MyGUI/mygui
    REF MyGUI${VERSION}
    SHA512 9b11cf5100b341962c07ec94f5076edb2f2d3a8d3649365261eda4945cd452069a9ced1db9083223873da9bf441b98a3dbbd65e7986de605a82c9a99f7ddc87f
    HEAD_REF master
    PATCHES
        ${PATCHES}
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
    message(STATUS "Setting MYGUI_RENDERSYSTEM to 8 (GLES) - officially supported MyGUI render system for wasm32")
    set(MYGUI_RENDERSYSTEM 8)
else()
    set(MYGUI_RENDERSYSTEM 1)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        plugins MYGUI_BUILD_PLUGINS
        tools MYGUI_BUILD_TOOLS
        msdf MYGUI_MSDF_FONTS
    INVERTED_FEATURES
        obsolete MYGUI_DONT_USE_OBSOLETE
        plugins MYGUI_DISABLE_PLUGINS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MYGUI_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" MSDFGEN_DYNAMIC_RUNTIME)

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
        -DMSDFGEN_DYNAMIC_RUNTIME=${MSDFGEN_DYNAMIC_RUNTIME}
        -DBUILD_SHARED_LIBS=${MSDFGEN_DYNAMIC_RUNTIME}
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        MSDFGEN_DYNAMIC_RUNTIME
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
