set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

string(LENGTH "${CURRENT_BUILDTREES_DIR}" buildtrees_path_length)
if(buildtrees_path_length GREATER 44 AND CMAKE_HOST_WIN32)
    vcpkg_buildpath_length_warning(44)
    message(WARNING "The ${PORT} source was will be extracted to ${CURRENT_BUILDTREES_DIR} , which has more then 44 characters in length.")
    message(FATAL_ERROR "terminating due to ${CURRENT_BUILDTREES_DIR} being too long.")
endif()

 set(TOOL_NAMES 
        qml
        qmlcachegen
        qmleasing
        qmlformat
        qmlimportscanner
        qmllint
        qmlplugindump
        qmlpreview
        qmlprofiler
        qmlscene
        qmltestrunner
        qmltime
        qmltyperegistrar
        qmldom
        qmltc
    )

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
