set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES )#fix_static_build.patch)

#TODO check features and setup: (means force features!)

# -- The following OPTIONAL packages have not been found:

 # * Qt6AxContainer
 # * Clang
 # * WrapLibClang (required version >= 8)

# Configure summary:

# Qt Tools:
  # Qt Assistant ........................... yes
  # QDoc ................................... no
  # Clang-based lupdate parser ............. no
  # Qt Designer ............................ yes
  # Qt Distance Field Generator ............ yes
  # kmap2qmap .............................. yes
  # Qt Linguist ............................ yes
  # Mac Deployment Tool .................... no
  # pixeltool .............................. yes
  # qdbus .................................. yes
  # qev .................................... yes
  # Qt Attributions Scanner ................ yes
  # qtdiag ................................. yes
  # qtpaths ................................ yes
  # qtplugininfo ........................... yes
  # Windows deployment tool ................ yes

# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "assistant" FEATURE_assistant
    "designer" FEATURE_designer
    "linguist" FEATURE_linguist
    INVERTED_FEATURES
    "qdoc"   CMAKE_DISABLE_FIND_PACKAGE_Clang
    "qdoc"   CMAKE_DISABLE_FIND_PACKAGE_WrapLibClang
    "qml"    CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    "qml"    CMAKE_DISABLE_FIND_PACKAGE_Qt6QuickWidgets
    )

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
        qtdiag6
        qtpaths
        qtplugininfo
        qdbus
        qdbusviewer
        qdoc
    )
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND TOOL_NAMES windeployqt)
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND TOOL_NAMES macdeployqt)
endif()

### Download third_party modules
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_QLITEHTML
    URL git://code.qt.io/playground/qlitehtml.git # git://code.qt.io/playground/qlitehtml.git
    REF 908670c5b68d3bcf4712019a028079b8b2042dd4
    FETCH_REF master
    HEAD_REF master
)
# port 'litehtml' is not in vcpkg!
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH_LITEHTML
    REPO litehtml/litehtml
    REF db7f59d5886fd50f84d48720c79dc2e6152efa83
    SHA512 6beed53f8b779359eb2d08495547f9b4e3d02b70d68e035e6c188f009a283e630b3961caa472ce045799a9ef82e1cd6b3c63d8534e6e8127441944f4837a0352
    HEAD_REF master
)

##### qt_install_submodule
set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()
file(COPY "${SOURCE_PATH_QLITEHTML}/" DESTINATION "${SOURCE_PATH}/src/assistant/qlitehtml")
file(COPY "${SOURCE_PATH_LITEHTML}/" DESTINATION "${SOURCE_PATH}/src/assistant/qlitehtml/src/3rdparty/litehtml")


if(_qis_DISABLE_NINJA)
    set(_opt DISABLE_NINJA)
endif()
qt_cmake_configure(${_opt} 
                   OPTIONS ${FEATURE_OPTIONS}
                           -DCMAKE_DISABLE_FIND_PACKAGE_Qt6AxContainer=ON
                   OPTIONS_DEBUG ${_qis_CONFIGURE_OPTIONS_DEBUG}
                   OPTIONS_RELEASE ${_qis_CONFIGURE_OPTIONS_RELEASE})

vcpkg_install_cmake(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

qt_install_copyright("${SOURCE_PATH}")

##### qt_install_submodule

if(VCPKG_TARGET_IS_OSX)
    set(OSX_APP_FOLDERS Designer.app Linguist.app pixeltool.app qdbusviewer.app)
    foreach(_appfolder IN LISTS OSX_APP_FOLDERS)
        message(STATUS "Moving: ${_appfolder}")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${_appfolder}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${_appfolder}/" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${_appfolder}/")
    endforeach()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

set(configfile "${CURRENT_PACKAGES_DIR}/share/Qt6ToolsTools/Qt6ToolsToolsTargets-debug.cmake")
if(EXISTS "${configfile}" AND EXISTS "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin/windeployqt.exe")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/windeployqt.debug.bat" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/Qt6/bin")
    file(READ "${configfile}" _contents)
    string(REPLACE [[${_IMPORT_PREFIX}/tools/Qt6/bin/windeployqt.exe]] [[${_IMPORT_PREFIX}/tools/Qt6/bin/windeployqt.debug.bat]] _contents "${_contents}")
    file(WRITE "${configfile}" "${_contents}")
endif()

file(GLOB_RECURSE debug_dir "${CURRENT_PACKAGES_DIR}/debug/*")
list(LENGTH debug_dir debug_dir_elements)
if(debug_dir_elements EQUAL 0)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()
