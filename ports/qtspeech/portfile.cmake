set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES
    silence-qtspeech-coroutine-warnings.diff
)
set(TOOL_NAMES)

# Note: flite is not implemented in the manifest yet (missing port for flite)
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "flite"         FEATURE_flite
    "speechd"       FEATURE_speechd
INVERTED_FEATURES
    "flite"         CMAKE_DISABLE_FIND_PACKAGE_Flite
    "speechd"       CMAKE_DISABLE_FIND_PACKAGE_SpeechDispatcher
)

if("speechd" IN_LIST FEATURES)
    # FindSpeechDispatcher.cmake uses pkg-config
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND FEATURE_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
                     CONFIGURE_OPTIONS_MAYBE_UNUSED
                         QT_BUILD_EXAMPLES
                         QT_USE_DEFAULT_CMAKE_OPTIMIZATION_FLAGS
                    )
