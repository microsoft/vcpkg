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
    #"iconv"         CMAKE_REQUIRE_FIND_PACKAGE_WrapIconv
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
INVERTED_FEATURES
    "iconv"         CMAKE_DISABLE_FIND_PACKAGE_WrapIconv
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    )

#For iconv feature to work the following must be true:
#CONDITION NOT FEATURE_icu AND FEATURE_textcodec AND NOT WIN32 AND NOT QNX AND NOT ANDROID AND NOT APPLE AND WrapIconv_FOUND
if("iconv" IN_LIST FEATURES)
    include("${SCRIPT_PATH}/port_status.cmake")
    if(qtbase_with_icu)
        message(FATAL_ERROR "qtbase was built with ICU. The iconv feature is not compatible with ICU.")
    endif()
endif()

set(TOOL_NAMES)
qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )

#For my documentation:
# find_package(Qt6 ${PROJECT_VERSION} CONFIG REQUIRED COMPONENTS BuildInternals Core)
# find_package(Qt6 ${PROJECT_VERSION} QUIET CONFIG OPTIONAL_COMPONENTS Network Xml Gui Quick)
