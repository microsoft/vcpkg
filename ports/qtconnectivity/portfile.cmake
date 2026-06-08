set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES
    silence-qtconnectivity-coroutine-warnings.diff
)

set(ADDITIONAL_OPTIONS "")
if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "qtconnectivity requires the BlueZ development headers from the system package manager. "
    "They can be installed on Debian/Ubuntu systems via sudo apt install libbluetooth-dev.")
    list(APPEND ADDITIONAL_OPTIONS -DFEATURE_bluez=ON)
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS
                      ${ADDITIONAL_OPTIONS}
                      -DCMAKE_DISABLE_FIND_PACKAGE_PCSCLITE:BOOL=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
