set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)

# General features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    # "appstore-compliant"  FEATURE_appstore-compliant
    # )

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
    )

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
                    
#TODO: 
# qt_feature("qml-network" PUBLIC
    # SECTION "QML"
    # LABEL "QML network support"
    # PURPOSE "Provides network transparency."
    # CONDITION FEATURE_network
# )
# qt_feature("qml-debug" PUBLIC
    # SECTION "QML"
    # LABEL "QML debugging and profiling support"
    # PURPOSE "Provides infrastructure and plugins for debugging and profiling."
# )
# qt_feature("quick-draganddrop" PUBLIC
    # SECTION "Qt Quick"
    # LABEL "Drag & Drop"
    # PURPOSE "Drag and drop support for Qt Quick"
    # CONDITION ( FEATURE_draganddrop ) AND ( FEATURE_regularexpression )
# )
# if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # file(GLOB_RECURSE STATIC_CMAKE_TARGETS "${CURRENT_PACKAGES_DIR}/share/Qt6Qml/QmlPlugins/*.cmake")
    # message(STATUS "PLUGIN_CMAKE_TARGETS:${PLUGIN_CMAKE_TARGETS}")
    # foreach(_plugin_target IN LISTS PLUGIN_CMAKE_TARGETS)
        # # restore a single get_filename_component which was remove by vcpkg_fixup_pkgconfig
        # vcpkg_replace_string("${_plugin_target}" 
                             # [[get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)]]
                             # [[get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
# get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)]])
    # endforeach()
# endif()