set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

message(WARNING "qtwayland requires libwayland-dev from your system package manager. You can install it with
sudo apt install libwayland-dev
on Ubuntu systems.")

set(${PORT}_PATCHES)

set(TOOL_NAMES qtwaylandscanner)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
INVERTED_FEATURES
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
