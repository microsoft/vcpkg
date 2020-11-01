set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)

# General features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    # "appstore-compliant"  QT_FEATURE_appstore-compliant
    # )

 set(TOOL_NAMES 
        assistant
        designer
        lconvert
        linguist
        lprodump
        lrelease-pro
        lrelease
        lupdate-pro
        lupdate
        pixeltool
        qcollectiongenerator
        qdistancefieldgenerator
        qhelpgenerator
        qtattributionsscanner
        qtdiag
        qtpaths
        qtplugininfo
    )
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND TOOL_NAMES windeployqt)
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )