set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)
set(TOOL_NAMES)

# Note: none of these features are implemented in the manifest yet
# flite -> Missing port for flite
# speechd -> missing port for speechd
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "flite"         FEATURE_flite
    "flite-alsa"    FEATURE_flite-alsa
    "speechd"       FEATURE_speechd
INVERTED_FEATURES
    "flite"         CMAKE_DISABLE_FIND_PACKAGE_Flite
    "flite-alsa"    CMAKE_DISABLE_FIND_PACKAGE_Alsa
    "speechd"       CMAKE_DISABLE_FIND_PACKAGE_SpeechDispatcher
)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_MAYBE_UNUSED
                         QT_BUILD_EXAMPLES
                         QT_USE_DEFAULT_CMAKE_OPTIMIZATION_FLAGS
                    )
