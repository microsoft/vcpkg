set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

 set(TOOL_NAMES
        canbusutil
    )

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "modbus-serialport" FEATURE_modbus_serialport
INVERTED_FEATURES
    "modbus-serialport" CMAKE_DISABLE_FIND_PACKAGE_Qt6SerialPort
)
# Probably not worth the time to make it features:
# qt_configure_add_summary_entry(ARGS "socketcan") # only unix
# qt_configure_add_summary_entry(ARGS "socketcan_fd") # only unix
# qt_configure_add_summary_entry(ARGS "modbus-serialport")

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
