vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO texus/TGUI
    REF 5ee202f93a280744a2bbf92c12f693510f69dbcf # v0.8.7
    SHA512 cc1e360add00fa6b6a2b44b83b82715dcbfa3f47768dd465acbd7df9fac1fc5283d63468cdf60557360448c07fb6ba36eb24c53f53883b04495f478c62b80718
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
