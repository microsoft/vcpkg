set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "textcodec"     FEATURE_textcodec
    "codecs"        FEATURE_codecs
    "big-codecs"    FEATURE_big_codecs
    "iconv"         FEATURE_iconv
    "iconv"         CMAKE_DISABLE_FIND_PACKAGE_ICU
INVERTED_FEATURES
    "iconv"         CMAKE_DISABLE_FIND_PACKAGE_WrapIconv
    )

#For iconv feature to work the following must be true:
#CONDITION NOT FEATURE_icu AND FEATURE_textcodec AND NOT WIN32 AND NOT QNX AND NOT ANDROID AND NOT APPLE AND WrapIconv_FOUND
#TODO: check if qtbase was built with ICU and fail if iconv is given here.

set(TOOL_NAMES)
qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
