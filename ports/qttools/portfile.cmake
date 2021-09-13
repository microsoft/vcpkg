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
    INVERTED_FEATURES
    "qdoc"  CMAKE_DISABLE_FIND_PACKAGE_Clang
    "qdoc"  CMAKE_DISABLE_FIND_PACKAGE_WrapLibClang
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

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                                       -DCMAKE_DISABLE_FIND_PACKAGE_Qt6AxContainer=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
                    
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
