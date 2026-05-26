set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES
    silence-qtconnectivity-coroutine-warnings.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS feature_options
    FEATURES
        bluez FEATURE_bluez
)

if("bluez" IN_LIST FEATURES)
    message(WARNING "qtconnectivity[bluez] requires the BlueZ development headers from the system package manager. "
    "They can be installed on Debian/Ubuntu systems via sudo apt install libbluetooth-dev.")
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS
                      ${feature_options}
                      -DCMAKE_DISABLE_FIND_PACKAGE_PCSCLITE:BOOL=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
