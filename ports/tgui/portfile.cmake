vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO texus/TGUI
    REF 6515153c2466e6677ba933679b3dca6c283daf87
    SHA512 109e64c114336979a4bd0d44765e4bc26cb4ecb6e4db92d7441230d148438b084d01cb56dd292f09a6fd28b0f7420044455ffb519147cc3aea71e322142cd9a0
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
    tool    TGUI_BUILD_GUI_BUILDER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
        -DTGUI_MISC_INSTALL_PREFIX=${TGUI_SHARE_PATH}
        -DTGUI_SHARED_LIBS=${TGUI_SHARED_LIBS}
        -DTGUI_BACKEND=Custom
        -DTGUI_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TGUI)
vcpkg_copy_pdbs()

if("tool" IN_LIST FEATURES)
    message(STATUS "Check for: ${TGUI_SHARE_PATH}/gui-builder/gui-builder${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    if(EXISTS "${TGUI_SHARE_PATH}/gui-builder/gui-builder${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        file(MAKE_DIRECTORY "${TGUI_TOOLS_PATH}")
        file(RENAME
            "${TGUI_SHARE_PATH}/gui-builder/gui-builder${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
            "${TGUI_TOOLS_PATH}/gui-builder${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        # Need to copy `resources` and `themes` directories
        file(COPY "${TGUI_SHARE_PATH}/gui-builder/resources" DESTINATION "${TGUI_TOOLS_PATH}")
        file(COPY "${TGUI_SHARE_PATH}/gui-builder/themes" DESTINATION "${TGUI_TOOLS_PATH}")
        file(REMOVE_RECURSE "${TGUI_SHARE_PATH}/gui-builder")
        vcpkg_copy_tool_dependencies("${TGUI_TOOLS_PATH}")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/TGUI/extlibs/nanosvg" "${CURRENT_PACKAGES_DIR}/include/TGUI/extlibs/glad"
     "${CURRENT_PACKAGES_DIR}/include/TGUI/extlibs/stb"
) # All folders are empty

file(RENAME "${CURRENT_PACKAGES_DIR}/share/doc" "${CURRENT_PACKAGES_DIR}/share/${PORT}/doc")

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
