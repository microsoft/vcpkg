set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

 set(TOOL_NAMES 
        canbusutil
    )

# Probably not worth the time to make it features:
# qt_configure_add_summary_entry(ARGS "socketcan") # only unix
# qt_configure_add_summary_entry(ARGS "socketcan_fd") # only unix
# qt_configure_add_summary_entry(ARGS "modbus-serialport")

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
