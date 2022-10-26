set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)

set(TOOL_NAMES qsb)

file(INSTALL "${CURRENT_INSTALLED_DIR}/share/Qt6Gui/Qt6QEglFSX11IntegrationPluginTargets.cmake" DESTINATION "${CURRENT_BUILDTREES_DIR}" RENAME "Qt6QEglFSX11IntegrationPluginTargets.cmake.log")
qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        --trace-expand
                        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
