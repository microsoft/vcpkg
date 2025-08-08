set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES
    devendor-litehtml.patch
  )

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
    "qdbus" FEATURE_qdbus
    "qdoc"   CMAKE_REQUIRE_FIND_PACKAGE_Clang
    #"qdoc"   CMAKE_REQUIRE_FIND_PACKAGE_WrapLibClang
    "qml"    CMAKE_REQUIRE_FIND_PACKAGE_Qt6Qml
    "qml"    CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
    "qml"    CMAKE_REQUIRE_FIND_PACKAGE_Qt6QuickWidgets
    "qml"    FEATURE_distancefieldgenerator
    INVERTED_FEATURES
    "qdoc"   CMAKE_DISABLE_FIND_PACKAGE_Clang
    "qdoc"   CMAKE_DISABLE_FIND_PACKAGE_WrapLibClang
    "qml"    CMAKE_DISABLE_FIND_PACKAGE_Qt6Qml
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

set(unused "")
if(NOT "assistant" IN_LIST FEATURES)
  list(APPEND unused QLITEHTML_USE_SYSTEM_LITEHTML CMAKE_REQUIRE_FIND_PACKAGE_litehtml)
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS 
                           ${FEATURE_OPTIONS}
                           -DCMAKE_DISABLE_FIND_PACKAGE_Qt6AxContainer=ON
                           -DQLITEHTML_USE_SYSTEM_LITEHTML:BOOL=ON
                           -DCMAKE_REQUIRE_FIND_PACKAGE_litehtml:BOOL=ON
                     CONFIGURE_OPTIONS_MAYBE_UNUSED
                            ${unused}
                    )

if(VCPKG_TARGET_IS_OSX)
    set(OSX_APP_FOLDERS Designer.app Linguist.app pixeltool.app)
    if (FEATURE_qdbus)
        message(STATUS "Built qdbusviewer")
        list(APPEND OSX_APP_FOLDERS qdbusviewer.app)
    endif()
    foreach(_appfolder IN LISTS OSX_APP_FOLDERS)
        # Folders are only existing in case of native builds 
        if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_appfolder}")
            message(STATUS "Moving: ${_appfolder}")
            file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${_appfolder}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${_appfolder}/" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/${_appfolder}/")
        endif()    
    endforeach()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(GLOB_RECURSE debug_dir "${CURRENT_PACKAGES_DIR}/debug/*")
list(LENGTH debug_dir debug_dir_elements)
if(debug_dir_elements EQUAL 0)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()
