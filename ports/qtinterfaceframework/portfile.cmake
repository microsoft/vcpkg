set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES "")
set(TOOL_NAMES "")

#[submodule "src/3rdparty/qface"]
#	path = src/3rdparty/qface
#	url = ../qtinterfaceframework-qface.git
#[submodule "src/3rdparty/taglib/taglib"] # Is in vcpkg
#	path = src/3rdparty/taglib/taglib
#	url = ../qtinterfaceframework-taglib.git
#	branch = upstream/master

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_QFACE
    URL git://code.qt.io/qt/qtinterfaceframework-qface.git
    REF 4f4027b4bb677eafad0bfb2593226b71ee2c98e6
    FETCH_REF upstream/master
    HEAD_REF upstream/master
)

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()
file(COPY "${SOURCE_PATH_QFACE}/" DESTINATION "${SOURCE_PATH}/src/3rdparty/qface")

if(_qis_DISABLE_NINJA)
    set(_opt DISABLE_NINJA)
endif()

qt_cmake_configure(${_opt} 
                   OPTIONS ${FEATURE_OPTIONS}
                   OPTIONS_DEBUG ${_qis_CONFIGURE_OPTIONS_DEBUG}
                   OPTIONS_RELEASE ${_qis_CONFIGURE_OPTIONS_RELEASE})

vcpkg_install_cmake(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

qt_install_copyright("${SOURCE_PATH}")

