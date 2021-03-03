## All above goes into the qt_port_hashes in the future
include("${CMAKE_CURRENT_LIST_DIR}/cmake/qt_install_submodule.cmake")

set(${PORT}_PATCHES 
        #2548438.diff
        jpeg.patch
        harfbuzz.patch
        config_install.patch 
        allow_outside_prefix.patch 
        buildcmake.patch
        dont_force_cmakecache.patch
        fix_find_dep.patch
        )

if(NOT VCPKG_USE_HEAD_VERSION)
    list(APPEND ${PORT}_PATCHES
                )
endif()

# Features can be found via searching for qt_feature in all configure.cmake files in the source: 
# The files also contain information about the Platform for which it is searched
# Always use FEATURE_<feature> in vcpkg_configure_cmake
# (using QT_FEATURE_X overrides Qts condition check for the feature.)
# Theoretically there is a feature for every widget to enable/disable it but that is way to much for vcpkg

set(input_vars doubleconversion freetype harfbuzz libb2 jpeg libmd4c png sql-sqlite)
set(INPUT_OPTIONS)
foreach(_input IN LISTS input_vars)
    if(_input MATCHES "(png|jpeg)" )
        list(APPEND INPUT_OPTIONS -DINPUT_lib${_input}:STRING=)
    elseif(_input MATCHES "(sql-sqlite)")
        list(APPEND INPUT_OPTIONS -DINPUT_sqlite:STRING=) # Not yet used be the cmake build
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
    "appstore-compliant"  FEATURE_appstore-compliant
    "zstd"                FEATURE_zstd
    "framework"           FEATURE_framework
    "concurrent"          FEATURE_concurrent
    "dbus"                FEATURE_dbus
    "gui"                 FEATURE_gui
    "network"             FEATURE_network
    "sql"                 FEATURE_sql
    "widgets"             FEATURE_widgets
    "xml"                 FEATURE_xml
    "testlib"             FEATURE_testlib
INVERTED_FEATURES
    "zstd"              CMAKE_DISABLE_FIND_PACKAGE_ZSTD
    "dbus"              CMAKE_DISABLE_FIND_PACKAGE_WrapDBus1
    )

list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libudev:BOOL=ON)

# Corelib features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_CORE_OPTIONS
FEATURES
    "doubleconversion"    FEATURE_doubleconversion
    "glib"                FEATURE_glib
    "icu"                 FEATURE_icu
    "pcre2"               FEATURE_pcre2
INVERTED_FEATURES
    "doubleconversion"      CMAKE_DISABLE_FIND_PACKAGE_WrapDoubleConversion
    "icu"                   CMAKE_DISABLE_FIND_PACKAGE_ICU
    "pcre2"                 CMAKE_DISABLE_FIND_PACKAGE_WrapSystemPCRE2
    "glib"                 CMAKE_DISABLE_FIND_PACKAGE_GLIB2
    )

list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_LTTngUST:BOOL=ON)
list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_PPS:BOOL=ON)
list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Slog2:BOOL=ON)
list(APPEND FEATURE_CORE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libsystemd:BOOL=ON)


# Network features:
 vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_NET_OPTIONS
 FEATURES
    "openssl"             FEATURE_openssl
    "brotli"              FEATURE_brotli
 INVERTED_FEATURES
    "brotli"              CMAKE_DISABLE_FIND_PACKAGE_WrapBrotli
    "openssl"             CMAKE_DISABLE_FIND_PACKAGE_WrapOpenSSL
    )

if("openssl" IN_LIST FEATURES)
    list(APPEND FEATURE_NET_OPTIONS -DINPUT_openssl=linked)
else()
    list(APPEND FEATURE_NET_OPTIONS -DINPUT_openssl=no)
endif()

list(APPEND FEATURE_NET_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libproxy:BOOL=ON)
list(APPEND FEATURE_NET_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_GSSAPI:BOOL=ON)

#INPUT_securetransport #Apple
#INPUT_schannel #Windows
#AUTODETECTED features
#FEATURE_getifaddrs
#ipv6ifname

# Gui features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_GUI_OPTIONS
    FEATURES
    "freetype"            FEATURE_freetype
    "harfbuzz"            FEATURE_harfbuzz
    "fontconfig"          FEATURE_fontconfig # NOT WINDOWS
    "jpeg"                FEATURE_jpeg
    "png"                 FEATURE_png
    #"opengl"              INPUT_opengl=something
    INVERTED_FEATURES
    "vulkan"              CMAKE_DISABLE_FIND_PACKAGE_Vulkan
    "egl"                 CMAKE_DISABLE_FIND_PACKAGE_EGL
    "fontconfig"          CMAKE_DISABLE_FIND_PACKAGE_Fontconfig
    "freetype"            CMAKE_DISABLE_FIND_PACKAGE_WrapSystemFreetype
    "harfbuzz"            CMAKE_DISABLE_FIND_PACKAGE_WrapSystemHarfbuzz
    "jpeg"                CMAKE_DISABLE_FIND_PACKAGE_JPEG
    "png"                 CMAKE_DISABLE_FIND_PACKAGE_PNG
    "xlib"                CMAKE_DISABLE_FIND_PACKAGE_X11
    "xkb"                 CMAKE_DISABLE_FIND_PACKAGE_XKB
    "xcb"                 CMAKE_DISABLE_FIND_PACKAGE_XCB
    "xcb-xlib"            CMAKE_DISABLE_FIND_PACKAGE_X11_XCB
    "xkbcommon-x11"       CMAKE_DISABLE_FIND_PACKAGE_XKB_COMMON_X11
    "xrender"             CMAKE_DISABLE_FIND_PACKAGE_XRender
    # There are more X features but I am unsure how to safely disable them! Most of them seem to be found automaticall with find_package(X11)
     )

if("xcb" IN_LIST FEATURES)
    list(APPEND FEATURE_GUI_OPTIONS -DINPUT_xcb=yes)
else()
    list(APPEND FEATURE_GUI_OPTIONS -DINPUT_xcb=no)
endif()
if("xkb" IN_LIST FEATURES)
    list(APPEND FEATURE_GUI_OPTIONS -DINPUT_xkbcommon=yes)
else()
    list(APPEND FEATURE_GUI_OPTIONS -DINPUT_xkbcommon=no)
endif()
list(APPEND FEATURE_GUI_OPTIONS )

list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_ATSPI2:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_DirectFB:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libdrm:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_gbm:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Libinput:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Mtdev:BOOL=ON)
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_GLESv2:BOOL=ON) # only used if INPUT_opengl is correctly set
list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Tslib:BOOL=ON)
if(VCPKG_TARGET_IS_LINUX)
    #list(APPEND FEATURE_GUI_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Wayland:BOOL=ON) Does not seem necessary
endif()
# sql-drivers features:

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_SQLDRIVERS_OPTIONS
    FEATURES
    "sql-sqlite"          FEATURE_system_sqlite
    INVERTED_FEATURES
    "sql-psql"            CMAKE_DISABLE_FIND_PACKAGE_PostgreSQL
    "sql-sqlite"          CMAKE_DISABLE_FIND_PACKAGE_SQLite3
    
    # "sql-db2"             FEATURE_sql-db2
    # "sql-ibase"           FEATURE_sql-ibase
    # "sql-mysql"           FEATURE_sql-mysql
    # "sql-oci"             FEATURE_sql-oci
    # "sql-odbc"            FEATURE_sql-odbc
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
    # "gtk3"             FEATURE_gtk3
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
# FEATURE_glibc
# FEATURE_gssapi
# FEATURE_ltcg
# FEATURE_opengl _dynamic _desktop 
# FEATURE_opengles2 3 31 32
# FEATURE_openssl _linked _runtime
# FEATURE_optimize_full _size
# FEATURE_pkg_config
# FEATURE_reduce_exports
# FEATURE_reduce_relocations
# FEATURE_win32_system_libs?


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
                        #--trace-expand
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
                        -DINPUT_bundled_xcb_xinput:STRING=no
                        -DFEATURE_force_debug_info:BOOL=ON
                        -DFEATURE_relocatable:BOOL=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                        -DQT_NO_MAKE_TOOLS:BOOL=ON
                        -DFEATURE_debug:BOOL=ON
                    )

# Install CMake helper scripts
if(QT_IS_LATEST)
    set(port_details "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_port_details-latest.cmake") 
else()
    set(port_details "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_port_details.cmake") 
endif()
file(COPY
    "${port_details}"
    "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_install_copyright.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/cmake/qt_install_submodule.cmake"
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    )

qt_stop_on_update()

set(script_files qt-cmake qt-cmake-private qt-cmake-standalone-test qt-configure-module qt-internal-configure-tests)
if(VCPKG_TARGET_IS_WINDOWS)
    set(script_suffix .bat)
else()
    set(script_suffix)
endif()
set(other_files 
        qt-cmake-private-install.cmake 
        syncqt.pl
        android_cmakelist_patcher.sh
        android_emulator_launcher.sh
        ensure_pro_file.cmake
        )
foreach(_config debug release)
    if(_config MATCHES "debug")
        set(path_suffix debug/)
    else()
        set(path_suffix)
    endif()
    if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/${path_suffix}bin")
        continue()
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


if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(GLOB_RECURSE _bin_files "${CURRENT_PACKAGES_DIR}/bin/*")

    if(NOT _bin_files) # Only clean if empty otherwise let vcpkg throw and error. 
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/" "${CURRENT_PACKAGES_DIR}/debug/bin/")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Qt6/QtBuildInternals")

if(NOT VCPKG_TARGET_IS_OSX)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Qt6/macos")
endif()

#TODO. create qt.conf for vcpkg_configure_qmake
