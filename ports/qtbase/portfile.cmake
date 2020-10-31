set(${PORT}_REF v6.0.0-beta2)
set(${PORT}_HASH 271c4ca2baa12b111837b36f2f2aed51ef84a62e2a3b8f9185a004330cb0a4c9398cf17468b134664de70ad175f104e77fa2a848466d33004739cdcb82d339ea)

## All above goes into the qt_port_hashes in the future
include("${CMAKE_CURRENT_LIST_DIR}/cmake/qt_port_hashes.cmake")

vcpkg_find_acquire_program(PERL) # Perl is probably required by all qt ports for syncqt
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})


set(${PORT}_PATCHES jpeg.patch findzstd.patch config_install.patch allow_outside_prefix.patch harfbuzz.patch)

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

set(input_vars doubleconversion freetype harfbuzz libb2 jpeg libmd4c png sql-sqlite)
set(INPUT_OPTIONS)
foreach(_input IN LISTS input_vars)
    if(_input MATCHES "(png|jpeg)" )
        list(APPEND INPUT_OPTIONS -DINPUT_lib${_input}:STRING=)
    elseif(_input MATCHES "(sql-sqlite)")
        list(APPEND INPUT_OPTIONS -DINPUT_sqlite:STRING=)
    else()
        list(APPEND INPUT_OPTIONS -DINPUT_${_input}:STRING=)
    endif()
    if("${_input}" IN_LIST FEATURES)
        string(APPEND INPUT_OPTIONS system)
    elseif(_input STREQUAL "libb2" AND NOT VCPKG_TARGET_IS_WINDOWS)
        string(APPEND INPUT_OPTIONS system)
    else()
        string(APPEND INPUT_OPTIONS no)
    endif()
endforeach()

# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_CORE_OPTIONS
    "appstore-compliant"  QT_FEATURE_appstore-compliant
    "zstd"                QT_FEATURE_zstd
    "framework"           QT_FEAUTRE_framework
    "concurrent"          QT_FEAUTRE_concurrent
    "dbus"                QT_FEAUTRE_dbus
    "gui"                 QT_FEAUTRE_gui
    "network"             QT_FEAUTRE_network
    "sql"                 QT_FEAUTRE_sql
    "widgets"             QT_FEAUTRE_widgets
    "xml"                 QT_FEAUTRE_xml
    "testlib"             QT_FEAUTRE_testlib
    )

# Corelib features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_CORE_OPTIONS
    "doubleconversion"    QT_FEATURE_doubleconversion
    #"doubleconversion"    QT_FEATURE_system-doubleconversion
    # "glib"                QT_FEATURE_glib
    "icu"                 QT_FEATURE_icu
    "pcre2"               QT_FEATURE_pcre2
    #"pcre2"               QT_FEATURE_system-pcre2
    )

if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_CORE_OPTIONS QT_FEATURE_system-libb2:BOOL=ON)
endif()

# Network features:
 vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_NET_OPTIONS
    "openssl"             QT_FEATURE_openssl
    "openssl"             QT_FEATURE_openssl-linked #'*
    "brotli"              QT_FEATURE_brotli
    )

# Gui features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_GUI_OPTIONS
    "freetype"            QT_FEATURE_freetype
    #"freetype"            QT_FEATURE_system-freetype
    "harfbuzz"            QT_FEATURE_harfbuzz # Currently requires pkg-config
    #"harfbuzz"            QT_FEATURE_system-harfbuzz
    "fontconfig"          QT_FEATURE_fontconfig # NOT WINDOWS
    # "gif"                 QT_FEATURE_gif
    # "ico"                 QT_FEATURE_ico
    "jpeg"                QT_FEATURE_jpeg
    #"jpeg"                QT_FEATURE_system-jpeg
    "png"                 QT_FEATURE_png
    #"png"                 QT_FEATURE_system-png
    # "opengl"              QT_FEATURE_opengl
    # "egl"                 QT_FEATURE_egl
    #"xlib"                QT_FEATURE_xlib
    #"xcb"                 QT_FEATURE_xcb
    #"xcb-xlib"            QT_FEATURE_xcb-xlib
    "vulkan"              QT_FEATURE_vulkan
     )

# sql-drivers features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_SQLDRIVERS_OPTIONS
    "sql-psql"            QT_FEATURE_sql-psql       #'*
    "sql-sqlite"          QT_FEATURE_sql-sqlite     #'*
    "sql-sqlite"          QT_FEATURE_system-sqlite  #'*
    # "sql-db2"             QT_FEATURE_sql-db2
    # "sql-ibase"           QT_FEATURE_sql-ibase
    # "sql-mysql"           QT_FEATURE_sql-mysql
    # "sql-oci"             QT_FEATURE_sql-oci
    # "sql-odbc"            QT_FEATURE_sql-odbc
    )

# printsupport features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_PRINTSUPPORT_OPTIONS
    # )

# widgets features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_WIDGETS_OPTIONS
    # "gtk3"             QT_FEATURE_gtk3
    # There are a lot of additional features here to deactivate parts of widgets. 
    # )


# QT_
# FEATURE_cups
# FEATURE_dbus_linked
# FEATURE_ egl egl_x11 eglfs eglfs _brcm _egldevice _gbm _mali _openwfd _rcar _viv _viv_wl _vsp2 _x11
# FEATURE_etw
# FEATURE_evdev
# FEATURE_eventfd
# FEATURE_glib
# FEATURE_glibc
# FEATURE_gssapi
# FEATURE_gtk3
# FEATURE_ltcg
# FEATURE_opengl _dynamic _desktop 
# FEATURE_opengles2 3 31 32
# FEATURE_openssl _linked _runtime
# FEATURE_optimize_full _size
# FEATURE_pkg_config
# FEATURE_reduce_exports
# FEATURE_reduce_relocations
# FEATURE_vulkan
# FEATURE_win32_system_libs?
# FEAUTRE_xcb _xlib
# FEATURE_xkbcommon _x11
# FEATURE_xlib

#TODO:
  # Manually-specified variables were not used by the project:

    # CMAKE_INSTALL_BINDIR
    # CMAKE_INSTALL_LIBDIR
    # INPUT_sqlite
    # QT_FEATURE_openssl-linked
    # QT_FEATURE_sql-psql
    # QT_FEATURE_sql-sqlite
    # QT_FEATURE_system-sqlite

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS 
        ${FEATURE_CORE_OPTIONS}
        ${FEATURE_NET_OPTIONS}
        ${FEATURE_GUI_OPTIONS}
        ${FEATURE_SQLDRIVERS_OPTIONS}
        ${FEATURE_PRINTSUPPORT_OPTIONS}
        ${FEATURE_WIDGETS_OPTIONS}
        ${INPUT_OPTIONS}
        #-DQT_HOST_PATH=<somepath> # For crosscompiling
        #-DQT_PLATFORM_DEFINITION_DIR=mkspecs/win32-msvc
        #-DQT_QMAKE_TARGET_MKSPEC=win32-msvc
        #-DQT_USE_CCACHE
        -DQT_NO_MAKE_EXAMPLES:BOOL=TRUE
        -DQT_NO_MAKE_TESTS:BOOL=TRUE
        #-DQT_NO_MAKE_TOOLS:BOOL=TRUE
        -DQT_USE_BUNDLED_BundledFreetype:BOOL=FALSE
        -DQT_USE_BUNDLED_BundledHarfbuzz:BOOL=FALSE
        -DQT_USE_BUNDLED_BundledLibpng:BOOL=FALSE
        -DQT_USE_BUNDLED_BundledPcre2:BOOL=FALSE
        #-DQT_FEATURE_icu:BOOL=ON
        #-DQT_FEATURE_system_doubleconversion:BOOL=ON
        #-DQT_FEATURE_system_freetype:BOOL=ON
        #-DQT_FEATURE_system_harfbuzz:BOOL=OFF
        #-DQT_FEATURE_harfbuzz:BOOL=OFF
        #-DQT_FEATURE_libb2:BOOL=OFF
        #-DQT_FEATURE_system_libb2:BOOL=OFF
        #-DQT_FEATURE_system_pcre2:BOOL=ON
        #-DQT_FEATURE_system_png:BOOL=ON
        #-DQT_FEATURE_system_zlib:BOOL=ON
        #-DQT_FEATURE_system_sqlite:BOOL=ON
        #-DQT_FEATURE_zstd:BOOL=ON
        -DQT_FEATURE_force_debug_info:BOOL=ON
        -DQT_FEATURE_relocatable:BOOL=ON
# Setup Qt syncqt (required for headers)
        -DHOST_PERL:PATH="${PERL}"
    OPTIONS_DEBUG
        -DQT_NO_MAKE_TOOLS:BOOL=ON
        -DQT_FEATURE_debug:BOOL=ON
        -DINSTALL_DOCDIR:STRING="../doc"
        -DINSTALL_INCLUDEDIR:STRING="../include"
        #-DINSTALL_MKSPECSDIR:STRING="../mkspecs" leaks into of buildtree/port
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/Qt6 TARGET_PATH share/Qt6)
set(COMPONENTS BuildInternals Concurrent Core CoreTools Core_qobject DBus DBusTools DeviceDiscoverySupport EntryPoint FbSupport Gui GuiTools HostInfo Network OpenGL OpenGLWidgets PrintSupport Sql Test Widgets WidgetsTools Xml)
foreach(_comp IN LISTS COMPONENTS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/share/Qt6${_comp}")
        vcpkg_fixup_cmake_targets(CONFIG_PATH share/Qt6${_comp} TARGET_PATH share/Qt6${_comp})
        # Would rather put it into share/cmake as before but the import_prefix correction in vcpkg_fixup_cmake_targets is working against that. 
    else()
        message(STATUS "WARNING: Qt component ${_comp} not found/built!")
    endif()
endforeach()

set(TOOL_NAMES androiddeployqt androidtestrunner cmake_automoc_parser moc qdbuscpp2xml qdbusxml2cpp qlalr qmake qvkgen rcc tracegen uic)
vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)

set(script_files qt-cmake qt-cmake-private qt-cmake-standalone-test qt-configure-module)
set(script_suffix .bat)
set(other_files qt-cmake-private-install.cmake syncqt.pl)
foreach(_config debug release)
    if(_config MATCHES "debug")
        set(path_suffix debug/)
    else()
        set(path_suffix)
    endif()
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${path_suffix}")
    foreach(script IN LISTS script_files)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/${path_suffix}bin/${script}${script_suffix}")
            set(target_script "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${path_suffix}/${script}${script_suffix}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/${path_suffix}bin/${script}${script_suffix}" "${target_script}")
            file(READ "${target_script}" _contents)
            if(_config MATCHES "debug")
                string(REPLACE "\\..\\share\\" "\\..\\..\\..\\share\\" _contents "${_contents}")
            else()
                string(REPLACE "\\..\\share\\" "\\..\\..\\share\\" _contents "${_contents}")
            endif()
            file(WRITE "${target_script}" "${_contents}")
        endif()
    endforeach()
    foreach(other IN LISTS other_files)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/${path_suffix}bin/${other}")
            file(RENAME "${CURRENT_PACKAGES_DIR}/${path_suffix}bin/${other}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${path_suffix}/${other}")
        endif()
    endforeach()
endforeach()

#TODO. move qtmain(d).lib into manual link (removed in beta2?)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/mkspecs"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/lib/cmake/"
                    "${CURRENT_PACKAGES_DIR}/share/cmake/Qt6/QtBuildInternals"
                    )

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/" "${CURRENT_PACKAGES_DIR}/debug/bin/")
endif()

if(NOT VCPKG_TARGET_IS_OSX)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/cmake/Qt6/macos"
                        )
endif()

include("${CMAKE_CURRENT_LIST_DIR}/cmake/qt_install_copyright.cmake")
qt_install_copyright("${SOURCE_PATH}")

# Instal Scripts
file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_port_hashes.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_install_copyright.cmake
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/qt
)
