vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO texus/TGUI
    REF 588362edc42772458fc232c5375a370aa7c449e1 # v0.9.1
    SHA512 3101be4c3f70c8cf6ea7a880fb97608c5fabb33ca14d87882efaf0a270eac3e594dc4afd9011962b290361ad2579d11e11d5157eda5163c3a3d00e41e8774f23
    HEAD_REF 0.9
    PATCHES
        fix-usage.patch
        fix-dependencies.patch
)

set(TGUI_SHARE_PATH ${CURRENT_PACKAGES_DIR}/share/tgui)
set(TGUI_TOOLS_PATH ${CURRENT_PACKAGES_DIR}/tools/tgui)

# Enable static build
file(REMOVE "${SOURCE_PATH}/cmake/Modules/FindSFML.cmake")
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" TGUI_SHARED_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    sdl2    TGUI_HAS_BACKEND_SDL
    sfml    TGUI_HAS_BACKEND_SFML
    tool    BUILD_GUI_BUILDER
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DTGUI_MISC_INSTALL_PREFIX=${TGUI_SHARE_PATH}
        -DTGUI_SHARED_LIBS=${TGUI_SHARED_LIBS}
        -DTGUI_BACKEND="Custom"
        -DTGUI_BUILD_EXAMPLES=OFF
        -DTGUI_BUILD_GUI_BUILDER=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/TGUI)
vcpkg_copy_pdbs()

if(BUILD_GUI_BUILDER)
    set(EXECUTABLE_SUFFIX "")
    if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(EXECUTABLE_SUFFIX ".exe")
    endif()

    message(STATUS "Check for: ${TGUI_SHARE_PATH}/gui-builder/gui-builder${EXECUTABLE_SUFFIX}")
    if(EXISTS "${TGUI_SHARE_PATH}/gui-builder/gui-builder${EXECUTABLE_SUFFIX}")
        file(MAKE_DIRECTORY "${TGUI_TOOLS_PATH}")
        file(RENAME
            "${TGUI_SHARE_PATH}/gui-builder/gui-builder${EXECUTABLE_SUFFIX}"
            "${TGUI_TOOLS_PATH}/gui-builder${EXECUTABLE_SUFFIX}")
        # Need to copy `resources` and `themes` directories
        file(COPY "${TGUI_SHARE_PATH}/gui-builder/resources" DESTINATION "${TGUI_TOOLS_PATH}")
        file(COPY "${TGUI_SHARE_PATH}/gui-builder/themes" DESTINATION "${TGUI_TOOLS_PATH}")
        file(REMOVE_RECURSE "${TGUI_SHARE_PATH}/gui-builder")
        vcpkg_copy_tool_dependencies("${TGUI_TOOLS_PATH}")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/TGUI/nanosvg" "${CURRENT_PACKAGES_DIR}/include/TGUI/extlibs/glad"
    "${CURRENT_PACKAGES_DIR}/include/TGUI/extlibs/nanosvg" "${CURRENT_PACKAGES_DIR}/include/TGUI/extlibs/stb"
)

file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc" "${CURRENT_PACKAGES_DIR}/share/${PORT}/doc")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
