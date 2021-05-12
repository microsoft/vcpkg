set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)

set(NO_BIN_AND_TOOLS FALSE)
if(VCPKG_TARGET_ARCHITECTURE MATCHES "^arm" AND VCPKG_TARGET_IS_WINDOWS)
    set(NO_BIN_AND_TOOLS TRUE)
endif()

if(NOT NO_BIN_AND_TOOLS)
    set(TOOL_NAMES 
            dumpcpp
            dumpdoc
            idc
            testcon
       )
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )

if(NO_BIN_AND_TOOLS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/tools")
endif()
