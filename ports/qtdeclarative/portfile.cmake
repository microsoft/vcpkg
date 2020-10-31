set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qt")
include("${SCRIPT_PATH}/qt_port_hashes.cmake")
include("${SCRIPT_PATH}/qt_install_copyright.cmake")

vcpkg_find_acquire_program(PERL) # Perl is probably required by all qt ports for syncqt
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

set(${PORT}_PATCHES)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qt/${PORT}
    REF ${${PORT}_REF}
    SHA512 ${${PORT}_HASH}
    HEAD_REF master
    PATCHES ${${PORT}_PATCHES}
)

# Features can be found via searching for qt_feature in all configure.cmake files in the source: 
# The files also contain information about the Platform for which it is searched
# Always use QT_FEATURE_<feature> in vcpkg_configure_cmake
# Theoretically there is a feature for every widget to enable/disable it but that is way to much for vcpkg

# General features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    # "appstore-compliant"  QT_FEATURE_appstore-compliant
    # "zstd"                QT_FEATURE_zstd
    # "framework"           QT_FEAUTRE_framework
    # "concurrent"          QT_FEAUTRE_concurrent
    # "dbus"                QT_FEAUTRE_dbus
    # "gui"                 QT_FEAUTRE_gui
    # "network"             QT_FEAUTRE_network
    # "sql"                 QT_FEAUTRE_sql
    # "widgets"             QT_FEAUTRE_widgets
    # "xml"                 QT_FEAUTRE_xml
    # "testlib"             QT_FEAUTRE_testlib
    # )

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS 
        ${FEATURE_OPTIONS}
        #-DQT_HOST_PATH=<somepath> # For crosscompiling
        #-DQT_PLATFORM_DEFINITION_DIR=mkspecs/win32-msvc
        #-DQT_QMAKE_TARGET_MKSPEC=win32-msvc
        #-DQT_USE_CCACHE
        -DQT_NO_MAKE_EXAMPLES:BOOL=TRUE
        -DQT_NO_MAKE_TESTS:BOOL=TRUE
        -DQT_FEATURE_force_debug_info:BOOL=ON
        -DQT_FEATURE_relocatable:BOOL=ON
# Setup Qt syncqt (required for headers)
        -DHOST_PERL:PATH="${PERL}"
        -DQT_SYNCQT:PATH="${CURRENT_INSTALLED_DIR}/tools/qtbase/syncqt.pl"
        -DINSTALL_DESCRIPTIONSDIR:STRING="modules"
        -DINSTALL_LIBEXECDIR:STRING="bin"
        -DINSTALL_PLUGINSDIR:STRING="plugins"
        -DINSTALL_QMLDIR:STRING="qml"
        -DINSTALL_TRANSLATIONSDIR:STRING="translations"
    OPTIONS_DEBUG
        -DQT_NO_MAKE_TOOLS:BOOL=ON
        -DQT_FEATURE_debug:BOOL=ON
        -DINSTALL_DOCDIR:STRING="../doc"
        -DINSTALL_INCLUDEDIR:STRING="../include"
        #-DINSTALL_MKSPECSDIR:STRING="../mkspecs" leaks into of buildtree/port
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

set(COMPONENTS)
foreach(_comp IN LISTS COMPONENTS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/share/cmake/Qt6${_comp}")
        vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/Qt6${_comp} TARGET_PATH share/cmake/Qt6${_comp})
    else()
        message(STATUS "WARNING: Qt component ${_comp} not found/built!")
    endif()
endforeach()

# set(TOOL_NAMES androiddeployqt androidtestrunner cmake_automoc_parser moc qdbuscpp2xml qdbusxml2cpp qlalr qmake qvkgen rcc tracegen uic)
# vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)

# set(script_files qt-cmake qt-cmake-private qt-cmake-standalone-test qt-configure-module)
# set(script_suffix .bat)
# set(other_files qt-cmake-private-install.cmake syncqt.pl)
# foreach(_config debug release)
    # if(_config MATCHES "debug")
        # set(path_suffix debug/)
    # else()
        # set(path_suffix)
    # endif()
    # file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${path_suffix}")
    # foreach(script IN LISTS script_files)
        # if(EXISTS "${CURRENT_PACKAGES_DIR}/${path_suffix}bin/${script}${script_suffix}")
            # set(target_script "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${path_suffix}/${script}${script_suffix}")
            # file(RENAME "${CURRENT_PACKAGES_DIR}/${path_suffix}bin/${script}${script_suffix}" "${target_script}")
            # file(READ "${target_script}" _contents)
            # if(_config MATCHES "debug")
                # string(REPLACE "\\..\\share\\" "\\..\\..\\..\\share\\" _contents "${_contents}")
            # else()
                # string(REPLACE "\\..\\share\\" "\\..\\..\\share\\" _contents "${_contents}")
            # endif()
            # file(WRITE "${target_script}" "${_contents}")
        # endif()
    # endforeach()
    # foreach(other IN LISTS other_files)
        # if(EXISTS "${CURRENT_PACKAGES_DIR}/${path_suffix}bin/${other}")
            # file(RENAME "${CURRENT_PACKAGES_DIR}/${path_suffix}bin/${other}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${path_suffix}/${other}")
        # endif()
    # endforeach()
# endforeach()

#TODO. move qtmain(d).lib into manual link (removed in beta2?)

# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/mkspecs"
                    # "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/"
                    # "${CURRENT_PACKAGES_DIR}/debug/share"
                    # "${CURRENT_PACKAGES_DIR}/lib/cmake/"
                    # "${CURRENT_PACKAGES_DIR}/share/cmake/Qt6/QtBuildInternals"
                    # )

# if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/" "${CURRENT_PACKAGES_DIR}/debug/bin/")
# endif()

# if(NOT VCPKG_TARGET_IS_OSX)
    # file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/cmake/Qt6/macos"
                        # )
# endif()

qt_install_copyright("${SOURCE_PATH}")