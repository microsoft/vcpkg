## All above goes into the qt_port_hashes in the future
include("${CMAKE_CURRENT_LIST_DIR}/cmake/qt_install_submodule.cmake")

set(${PORT}_PATCHES 
        jpeg.patch
        findzstd.patch
        fix_pcre2_linkage.patch
        harfbuzz.patch
        config_install.patch 
        allow_outside_prefix.patch 
        buildcmake.patch
        dont_force_cmakecache.patch
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
    elseif(_input STREQUAL "libmd4c")
        string(APPEND INPUT_OPTIONS qt) # libmd4c is not yet in VCPKG (but required by qtdeclarative)
    else()
        string(APPEND INPUT_OPTIONS no)
    endif()
endforeach()

# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_CORE_OPTIONS
FEATURES
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
INVERTED_FEATURES
    "zstd"              CMAKE_DISABLE_FIND_PACKAGE_ZSTD
    "dbus"              CMAKE_DISABLE_FIND_PACKAGE_WrapDBus1
    )

list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libudev:BOOL=ON)

# Corelib features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_CORE_OPTIONS
FEATURES
    "doubleconversion"    QT_FEATURE_doubleconversion
    # "glib"                QT_FEATURE_glib
    "icu"                 QT_FEATURE_icu
    "pcre2"               QT_FEATURE_pcre2
INVERTED_FEATURES
    "doubleconversion"      CMAKE_DISABLE_FIND_PACKAGE_WrapDoubleConversion
    "icu"                   CMAKE_DISABLE_FIND_PACKAGE_ICU
    "pcre2"                 CMAKE_DISABLE_FIND_PACKAGE_WrapSystemPCRE2
    #"glib"                 CMAKE_DISABLE_FIND_PACKAGE_GLIB2
    )

if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND FEATURE_CORE_OPTIONS QT_FEATURE_system-libb2:BOOL=ON)
endif()

list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_LTTngUST:BOOL=ON)
list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_PPS:BOOL=ON)
list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Slog2:BOOL=ON)
list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libsystemd:BOOL=ON)

# Network features:
 vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_NET_OPTIONS
 FEATURES
    "openssl"             QT_FEATURE_openssl
    "brotli"              QT_FEATURE_brotli
 INVERTED_FEATURES
    "brotli"              CMAKE_DISABLE_FIND_PACKAGE_WrapBrotli
    "openssl"             CMAKE_DISABLE_FIND_PACKAGE_WrapOpenSSL
    )

if("openssl" IN_LIST FEATURES)
    list(APPEND FEATURE_NET_OPTIONS -DINPUT_openssl=linked)
endif()

list(APPEND FEATURE_NET_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libproxy:BOOL=ON)
list(APPEND FEATURE_NET_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_GSSAPI:BOOL=ON)

# Gui features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_GUI_OPTIONS
    FEATURES
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
    INVERTED_FEATURES
    "vulkan"              CMAKE_DISABLE_FIND_PACKAGE_Vulkan
    "fontconfig"          CMAKE_DISABLE_FIND_PACKAGE_Fontconfig
    "freetype"            CMAKE_DISABLE_FIND_PACKAGE_WrapSystemFreetype
    "harfbuzz"            CMAKE_DISABLE_FIND_PACKAGE_WrapSystemHarfbuzz
    "jpeg"                CMAKE_DISABLE_FIND_PACKAGE_JPEG
    "png"                 CMAKE_DISABLE_FIND_PACKAGE_JPEG
     )

list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_ATSPI2:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_DirectFB:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libdrm:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_EGL:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_gbm:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libinput:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Mtdev:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_GLESv2:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Tslib:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Wayland:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_X11:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_XCB:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_X11_XCB:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_XKB:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_XKB_COMMON_X11:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_XRender:BOOL=ON)
# sql-drivers features:

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_SQLDRIVERS_OPTIONS
    FEATURES
    INVERTED_FEATURES
    "sql-psql"            CMAKE_DISABLE_FIND_PACKAGE_PostgreSQL
    "sql-sqlite"          CMAKE_DISABLE_FIND_PACKAGE_SQLite3
    # "sql-db2"             QT_FEATURE_sql-db2
    # "sql-ibase"           QT_FEATURE_sql-ibase
    # "sql-mysql"           QT_FEATURE_sql-mysql
    # "sql-oci"             QT_FEATURE_sql-oci
    # "sql-odbc"            QT_FEATURE_sql-odbc
    )

set(DB_LIST DB2 MySQL Oracle ODBC)
foreach(_db IN LISTS DB_LIST)
    list(APPEND FEATURE_SQLDRIVERS_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_${_db}:BOOL=ON)
endforeach()

# printsupport features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_PRINTSUPPORT_OPTIONS
    # )
list(APPEND FEATURE_PRINTSUPPORT_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_CUPS:BOOL=ON)

# widgets features:
# vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_WIDGETS_OPTIONS
    # "gtk3"             QT_FEATURE_gtk3
    # There are a lot of additional features here to deactivate parts of widgets. 
    # )
list(APPEND FEATURE_WIDGETS_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_GTK3:BOOL=ON)

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
# FEATURE_win32_system_libs?
# FEAUTRE_xcb _xlib
# FEATURE_xkbcommon _x11
# FEATURE_xlib

#TODO:
  # Manually-specified variables were not used by the project:

    # CMAKE_INSTALL_BINDIR
    # CMAKE_INSTALL_LIBDIR
    # INPUT_sqlite
set(TOOL_NAMES 
        androiddeployqt 
        androidtestrunner 
        cmake_automoc_parser 
        moc 
        qdbuscpp2xml 
        qdbusxml2cpp 
        qlalr 
        qmake 
        qvkgen 
        rcc 
        tracegen 
        uic
    )


qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_CORE_OPTIONS}
                        ${FEATURE_NET_OPTIONS}
                        ${FEATURE_GUI_OPTIONS}
                        ${FEATURE_SQLDRIVERS_OPTIONS}
                        ${FEATURE_PRINTSUPPORT_OPTIONS}
                        ${FEATURE_WIDGETS_OPTIONS}
                        ${INPUT_OPTIONS}
                        -DQT_USE_BUNDLED_BundledFreetype:BOOL=FALSE
                        -DQT_USE_BUNDLED_BundledHarfbuzz:BOOL=FALSE
                        -DQT_USE_BUNDLED_BundledLibpng:BOOL=FALSE
                        -DQT_USE_BUNDLED_BundledPcre2:BOOL=FALSE
                        -DQT_FEATURE_force_debug_info:BOOL=ON
                        -DQT_FEATURE_relocatable:BOOL=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                        -DQT_NO_MAKE_TOOLS:BOOL=ON
                        -DQT_FEATURE_debug:BOOL=ON)

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


if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND VCPKG_TARGET_IS_WINDOWS)
    file(GLOB_RECURSE _bin_files "${CURRENT_PACKAGES_DIR}/bin/*")
    if(NOT _bin_files) # Only clean if empty otherwise let vcpkg throw and error. 
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/" "${CURRENT_PACKAGES_DIR}/debug/bin/")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Qt6/QtBuildInternals")

if(NOT VCPKG_TARGET_IS_OSX)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Qt6/macos")
endif()

# Install Scripts
file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_port_hashes.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_install_copyright.cmake
    ${CMAKE_CURRENT_LIST_DIR}/cmake/qt_install_submodule.cmake
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

#TODO. create qt.conf for vcpkg_configure_qmake
