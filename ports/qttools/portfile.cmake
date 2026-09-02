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
        lcheck
        lconvert
        linguist
        lprodump
        lrelease-pro
        lrelease
        ltext2id
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

# Qt still has an older version of qlitehtml that is not compatible with current versions of litehtml
# We are using a modified version of qt_install_submodule here so that we can replace qlitehtml after downloading qttools.
# Revert this block when they updated it (check changes in 6.11.1#1).

### Begin modified qt_install_submodule
set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

qt_download_submodule(PATCHES ${${PORT}_PATCHES})

if(VCPKG_TARGET_IS_ANDROID)
    # Qt only supports dynamic linkage on Android,
    # https://bugreports.qt.io/browse/QTBUG-32618.
    # It requires libc++_shared, cf. <qtbase>/cmake/QtPlatformAndroid.cmake
    # and https://developer.android.com/ndk/guides/cpp-support#sr
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

if("assistant" IN_LIST FEATURES)
    set(qlitehtml_home "${SOURCE_PATH}/src/assistant/qlitehtml")
    file(REMOVE_RECURSE "${qlitehtml_home}")

    vcpkg_from_git(
        OUT_SOURCE_PATH SOURCE_PATH_QLITEHTML
        URL https://code.qt.io/playground/qlitehtml.git
        REF 89a544d4bc7c42b996a98ffa173457068c4e8713
        HEAD_REF master
        PATCHES
            fix-qlitehtml.patch
    )

    file(RENAME "${SOURCE_PATH_QLITEHTML}" "${qlitehtml_home}")
endif()

qt_cmake_configure(
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6AxContainer=ON
        -DQLITEHTML_USE_SYSTEM_LITEHTML:BOOL=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_litehtml:BOOL=ON
    OPTIONS_MAYBE_UNUSED
        ${unused}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

qt_install_copyright("${SOURCE_PATH}")
### End modified qt_install_submodule

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
