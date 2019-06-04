include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO texus/TGUI
    REF v0.8.5
    SHA512 36d8c29f246ca4d79d791f0368441762de0609d5cc0e507520ae0648ed3dc0bf47891582f283de241892bf9810f4d5049df46f566916d0bfffc383319d953002
    HEAD_REF 0.8
)

set(TGUI_SHARE_PATH ${CURRENT_PACKAGES_DIR}/share/tgui)
set(TGUI_TOOLS_PATH ${CURRENT_PACKAGES_DIR}/tools/tgui)

# Enable static build
file(REMOVE "${SOURCE_PATH}/cmake/Modules/FindSFML.cmake")
string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" TGUI_SHARED_LIBS)

# gui-builder
set(BUILD_GUI_BUILDER OFF)
if("tool" IN_LIST FEATURES)
    set(BUILD_GUI_BUILDER ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DTGUI_BUILD_GUI_BUILDER=${BUILD_GUI_BUILDER}
        -DTGUI_MISC_INSTALL_PREFIX=${TGUI_SHARE_PATH}
        -DTGUI_SHARED_LIBS=${TGUI_SHARED_LIBS}
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/TGUI/nanosvg")

# Handle copyright
file(RENAME "${CURRENT_PACKAGES_DIR}/share/tgui/license.txt" "${CURRENT_PACKAGES_DIR}/share/tgui/copyright")
