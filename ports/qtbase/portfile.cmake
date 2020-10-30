set(${PORT}_REF v6.0.0-beta1)
set(${PORT}_HASH 85a662990f014dd1c6c9bba3b541199c5e7e4535c6454cd3e78fbd4cfae977dc8ff370ae30fdd8068097b5a88ae069103546f54fb5f6b9c4597ed48e62fc1449)
set(${PORT}_PATCHES jpeg.patch findzstd.patch config_install.patch allow_outside_prefix.patch)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qt/${PORT}
    REF ${${PORT}_REF}
    SHA512 ${${PORT}_HASH}
    HEAD_REF master
    PATCHES ${${PORT}_PATCHES}
)
vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

# Features can be found via searching here: 
# qt_feature_evaluate_features("${CMAKE_CURRENT_SOURCE_DIR}/configure.cmake")
# qt_feature_evaluate_features("${CMAKE_CURRENT_SOURCE_DIR}/corelib/configure.cmake")
# qt_feature_evaluate_features("${CMAKE_CURRENT_SOURCE_DIR}/network/configure.cmake")
# qt_feature_evaluate_features("${CMAKE_CURRENT_SOURCE_DIR}/gui/configure.cmake")
# The files also contain information about the Platform for which it is searched
# Always use QT_FEATURE_<feature> in vcpkg_configure_cmake

# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_CORE_OPTIONS
    "appstore-compliant"  QT_FEATURE_appstore-compliant
    "zstd"                QT_FEATURE_zstd
    )

# Corelib features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_CORE_OPTIONS
    "doubleconversion"    QT_FEATURE_doubleconversion
    "doubleconversion"    QT_FEATURE_system-doubleconversion
    # "glib"                QT_FEATURE_glib
    "icu"                 QT_FEATURE_icu
    "pcre2"               QT_FEATURE_pcre2
    "pcre2"               QT_FEATURE_system-pcre2
    # "libb2"               QT_FEATURE_system-libb2
    )

# Network features:
 vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_NET_OPTIONS
    "openssl"             QT_FEATURE_openssl
    "openssl"             QT_FEATURE_openssl-linked
    "brotli"              QT_FEATURE_brotli
    )

# Gui features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_GUI_OPTIONS
    "freetype"            QT_FEATURE_freetype
    "freetype"            QT_FEATURE_system-freetype
    "harfbuzz"            QT_FEATURE_harfbuzz # Currently requires pkg-config
    "harfbuzz"            QT_FEATURE_system-harfbuzz
    "fontconfig"          QT_FEATURE_fontconfig # NOT WINDOWS
    # "gif"                 QT_FEATURE_gif
    # "ico"                 QT_FEATURE_ico
    "jpeg"                QT_FEATURE_jpeg
    "jpeg"                QT_FEATURE_system-jpeg
    "png"                 QT_FEATURE_png
    "png"                 QT_FEATURE_system-png
    # "opengl"              QT_FEATURE_opengl
    # "egl"                 QT_FEATURE_egl
     )

# sql-drivers features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_SQLDRIVERS_OPTIONS
    "sql-psql"            QT_FEATURE_sql-psql
    "sql-sqlite"          QT_FEATURE_sql-sqlite
    "sql-sqlite"          QT_FEATURE_system-sqlite
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


# QT_ FEATURE_appstore_compliant
# FEATURE_bortli
# FEATURE_cross_compile
# FEATURE_cups
# FEATURE_dbus
# FEATURE_dbus_linked
# FEATURE_doubleconversion
# FEATURE_ egl egl_x11 eglfs eglfs _brcm _egldevice _gbm _mali _openwfd _rcar _viv _viv_wl _vsp2 _x11
# FEATURE_etw
# FEATURE_evdev
# FEATURE_eventfd
# FEATURE_fontconfig
# FEATURE_freetype
# FEATURE_gif
# FEATURE_glib
# FEATURE_glibc
# FEATURE_gssapi
# FEATURE_gtk3
# FEATURE_harfbuzz
# FEATURE_icu
# FEATURE_jpeg
# FEATURE_ltcg
# FEATURE_opengl _dynamic _desktop 
# FEATURE_opengles2 3 31 32
# FEATURE_openssl _linked _runtime
# FEATURE_optimize_debug
# FEATURE_optimize_full _size
# FEATURE_pcre2
# FEATURE_pkg_config
# FEATURE_png
# FEATURE_reduce_exports
# FEATURE_reduce_relocations
# FEATURE_sql   _db2 _ibase _mysql _oci _odbc _psql _sqlite
# FEATURE_vulkan
# FEATURE_win32_system_libs?
# FEAUTRE_xcb _xlib
# FEATURE_xkbcommon _x11
# FEATURE_xlib
# FEATURE_xml
# FEATURE_zstd

# INPUT_doubleconversion
# INPUT_freetype
# INPUT_harfbuzz
# 
# INPUT_libjpeg
# INPUT_libmd4c
# INPUT_libpng
# INPUT_sqlite
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        ${FEATURE_CORE_OPTIONS}
        ${FEATURE_NET_OPTIONS}
        ${FEATURE_GUI_OPTIONS}
        ${FEATURE_SQLDRIVERS_OPTIONS}
        ${FEATURE_PRINTSUPPORT_OPTIONS}
        ${FEATURE_WIDGETS_OPTIONS}
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
        -DQT_FEATURE_system_doubleconversion:BOOL=ON
        -DQT_FEATURE_system_freetype:BOOL=ON
        #-DQT_FEATURE_system_harfbuzz:BOOL=OFF
        -DQT_FEATURE_harfbuzz:BOOL=OFF
        -DQT_FEATURE_libb2:BOOL=OFF
        #-DQT_FEATURE_system_libb2:BOOL=OFF
        -DQT_FEATURE_system_pcre2:BOOL=ON
        -DQT_FEATURE_system_png:BOOL=ON
        -DQT_FEATURE_system_zlib:BOOL=ON
        -DQT_FEATURE_system_sqlite:BOOL=ON
        -DQT_FEATURE_zstd:BOOL=ON
        -DQT_FEATURE_force_debug_info:BOOL=ON
        -DQT_FEATURE_relocatable:BOOL=ON
        -DQT_FEATURE_icu:BOOL=ON
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

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/Qt6 TARGET_PATH share/cmake/Qt6)
set(COMPONENTS BuildInternals BundledHarfbuzz Concurrent Core CoreTools Core_qobject DBus DBusTools DeviceDiscoverySupport FbSupport Gui GuiTools HostInfo Network OpenGL OpenGLWidgets PrintSupport Sql Test Widgets WidgetsTools WinMain Xml)
foreach(_comp IN LISTS COMPONENTS)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/share/cmake/Qt6${_comp}")
        vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/Qt6${_comp} TARGET_PATH share/cmake/Qt6${_comp})
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


#TODO. move qtmain(d).lib into manual link




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

if(EXISTS "${SOURCE_PATH}/LICENSE.LGPLv3")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.LGPLv3")
elseif(EXISTS "${SOURCE_PATH}/LICENSE.LGPL3")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.LGPL3")
elseif(EXISTS "${SOURCE_PATH}/LICENSE.GPLv3")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.GPLv3")
elseif(EXISTS "${SOURCE_PATH}/LICENSE.GPL3")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.GPL3")
elseif(EXISTS "${SOURCE_PATH}/LICENSE.GPL3-EXCEPT")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.GPL3-EXCEPT")
elseif(EXISTS "${SOURCE_PATH}/LICENSE.FDL")
    set(LICENSE_PATH "${SOURCE_PATH}/LICENSE.FDL")
endif()
file(INSTALL ${LICENSE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)