set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
message(STATUS "Upstream decided to split this into qtpositioning and qtlocation. qtlocation however is currently empty!")
# set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
# include("${SCRIPT_PATH}/qt_install_submodule.cmake")

# set(${PORT}_PATCHES)

# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
# FEATURES
# INVERTED_FEATURES
    # "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    # "nmea"          CMAKE_DISABLE_FIND_PACKAGE_Qt6SerialPort
    # "nmea"          CMAKE_DISABLE_FIND_PACKAGE_Qt6Network
# )

# list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_Gypsy=ON"
                            # "-DCMAKE_DISABLE_FIND_PACKAGE_Gconf=ON"
# )

# qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     # CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                     # CONFIGURE_OPTIONS_RELEASE
                     # CONFIGURE_OPTIONS_DEBUG
                    # )
