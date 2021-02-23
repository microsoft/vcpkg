set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)

# General features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    # "appstore-compliant"  FEATURE_appstore-compliant
    # )

 set(TOOL_NAMES qtwaylandscanner)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
