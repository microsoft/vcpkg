vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO texus/TGUI
    REF 6576c04e594ae0b76ff5e188d543a7558882ad6c # v0.8.8
    SHA512 52d044e90fde0eb6c46c3af3e11a6c8641cce301e863858701aaa909b945c76a1dade2f96a2176a223d92c51f84fe8a6dd883ec74873e8d2fcf09dac50869891
    HEAD_REF 0.8
)

set(TGUI_SHARE_PATH ${CURRENT_PACKAGES_DIR}/share/tgui)
set(TGUI_TOOLS_PATH ${CURRENT_PACKAGES_DIR}/tools/tgui)

# Enable static build
file(REMOVE "${SOURCE_PATH}/cmake/Modules/FindSFML.cmake")
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" TGUI_SHARED_LIBS)

# gui-builder
set(BUILD_GUI_BUILDER OFF)
if("tool" IN_LIST FEATURES)
    set(BUILD_GUI_BUILDER ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/TGUI/nanosvg")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
