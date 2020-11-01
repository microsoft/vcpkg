set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)

# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "assimp"  QT_FEATURE_assimp
INVERTED_FEATURES
    "assimp"  CMAKE_DISABLE_FIND_PACKAGE_WrapAssimp
    )
if("assimp" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_assimp=system)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_assimp=no)
endif()
 set(TOOL_NAMES balsam meshdebug shadergen)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
