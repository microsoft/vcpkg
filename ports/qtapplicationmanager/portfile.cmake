set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES bump-cmake-version.patch)

set(TOOL_NAMES)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        -DINPUT_libarchive=system
                        -DINPUT_libyaml=system
                        -DFEATURE_am_system_libyaml=ON
                        -DFEATURE_am_system_libarchive=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )

file(GLOB_RECURSE BIN_FILES "${CURRENT_PACKAGES_DIR}/bin/*")
message(STATUS "BIN_FILES:${BIN_FILES}")