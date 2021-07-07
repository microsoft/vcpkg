set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES forward_cmake_args.patch)

#QT_FEATURE_webengine_system_opus AND QT_FEATURE_webengine_system_libwebp
#QT_FEATURE_system_zlib
#webengine-system-libpng
#webengine-system-libjpeg
#webengine-system-harfbuzz
#webengine-system-freetype
#qt_feature("webengine-system-libpci" PRIVATE
#    LABEL "libpci"
#    CONDITION UNIX AND LIBPCI_FOUND
#)
# qt_feature("webengine-ozone-x11" PRIVATE
    # LABEL "Support qpa-xcb"
    # CONDITION LINUX
        # AND TARGET Qt::Gui
        # AND QT_FEATURE_xcb
        # AND X11_FOUND
        # AND LIBDRM_FOUND
        # AND XCOMPOSITE_FOUND
        # AND XCURSOR_FOUND
        # AND XI_FOUND
        # AND XPROTO_FOUND
        # AND XTST_FOUND
# )
# add_check_for_support(webEngineError webEngineSupport
   # MODULE QtWebEngine
   # CONDITION NOT LINUX OR TEST_glibc
   # MESSAGE "A suitable version >= 2.17 of glibc is required."
# )
# add_check_for_support(webEngineError webEngineSupport
   # MODULE QtWebEngine
   # CONDITION NOT LINUX OR TEST_khr
   # MESSAGE "Build requires Khronos development headers for build - see mesa/libegl1-mesa-dev"
# )
# dd_check_for_support(webEngineError webEngineSupport
   # MODULE QtWebEngine
   # CONDITION NOT LINUX OR FONTCONFIG_FOUND
   # MESSAGE "Build requires fontconfig."
# )
# add_check_for_support(webEngineError webEngineSupport
   # MODULE QtWebEngine
   # CONDITION NOT LINUX OR NSS_FOUND
   # MESSAGE "Build requires nss >= 3.26."
# )
# add_check_for_support(webEngineError webEngineSupport
   # MODULE QtWebEngine
   # CONDITION NOT LINUX OR DBUS_FOUND
   # MESSAGE "Build requires dbus."
# )
# if(UNIX)
    # qt_configure_add_summary_section(NAME "Optional system libraries")
    # qt_configure_add_summary_entry(ARGS "webengine-system-re2")
    # qt_configure_add_summary_entry(ARGS "webengine-system-icu")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libwebp")
    # qt_configure_add_summary_entry(ARGS "webengine-system-opus")
    # qt_configure_add_summary_entry(ARGS "webengine-system-ffmpeg")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libvpx")
    # qt_configure_add_summary_entry(ARGS "webengine-system-snappy")
    # qt_configure_add_summary_entry(ARGS "webengine-system-glib")
    # qt_configure_add_summary_entry(ARGS "webengine-system-zlib")
    # qt_configure_add_summary_entry(ARGS "webengine-system-minizip")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libevent")
    # qt_configure_add_summary_entry(ARGS "webengine-system-protobuf")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libxml")
    # qt_configure_add_summary_entry(ARGS "webengine-system-lcms2")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libpng")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libjpeg")
    # qt_configure_add_summary_entry(ARGS "webengine-system-harfbuzz")
    # qt_configure_add_summary_entry(ARGS "webengine-system-freetype")
    # qt_configure_add_summary_entry(ARGS "webengine-system-libpci")
    # qt_configure_end_summary_section()
# endif()

# qt_feature("webengine-embedded-build" PRIVATE
    # LABEL "Embedded build"
    # PURPOSE "Enables the embedded build configuration."
    # AUTODETECT CMAKE_CROSSCOMPILING
    # CONDITION UNIX
# )
# qt_feature("webengine-system-alsa" PRIVATE
    # LABEL "Use ALSA"
    # CONDITION UNIX AND TEST_alsa
# )
# qt_feature("webengine-v8-snapshot-support" PRIVATE
    # LABEL "Building v8 snapshot supported"
    # CONDITION NOT UNIX OR NOT QT_FEATURE_cross_compile OR ( TEST_architecture_arch STREQUAL arm64 ) OR TEST_webengine_host_compiler
# )
# qt_feature("webengine-geolocation" PUBLIC
    # LABEL "Geolocation"
    # CONDITION TARGET Qt::Positioning
# )
# qt_feature("webengine-system-pulseaudio" PRIVATE
    # LABEL "Use PulseAudio"
    # AUTODETECT UNIX
    # CONDITION PULSEAUDIO_FOUND
# )
# qt_feature("webengine-pepper-plugins" PRIVATE
    # LABEL "Pepper Plugins"
    # PURPOSE "Enables use of Pepper Flash plugins."
    # AUTODETECT NOT QT_FEATURE_webengine_embedded_build
# )
# qt_feature("webengine-printing-and-pdf" PRIVATE
    # LABEL "Printing and PDF"
    # PURPOSE "Provides printing and output to PDF."
    # AUTODETECT NOT QT_FEATURE_webengine_embedded_build
    # CONDITION TARGET Qt::PrintSupport AND QT_FEATURE_printer
# )
# qt_feature("webengine-webchannel" PUBLIC
    # SECTION "WebEngine"
    # LABEL "WebChannel support"
    # PURPOSE "Provides QtWebChannel integration."
    # CONDITION TARGET Qt::WebChannel
# )
# qt_feature("webengine-proprietary-codecs" PRIVATE
    # SECTION "WebEngine"
    # LABEL "Proprietary Codecs"
    # PURPOSE "Enables the use of proprietary codecs such as h.264/h.265 and MP3."
    # AUTODETECT OFF
# )
# qt_feature("webengine-kerberos" PRIVATE
    # SECTION "WebEngine"
    # LABEL "Kerberos Authentication"
    # PURPOSE "Enables Kerberos Authentication Support"
    # AUTODETECT WIN32
# )
# qt_feature("webengine-spellchecker" PUBLIC
    # LABEL "Spellchecker"
    # PURPOSE "Provides a spellchecker."
# )
# qt_feature("webengine-native-spellchecker" PUBLIC
    # LABEL "Native Spellchecker"
    # PURPOSE "Use the system's native spellchecking engine."
    # AUTODETECT OFF
    # CONDITION MACOS AND QT_FEATURE_webengine_spellchecker
# )
# qt_feature("webengine-extensions" PUBLIC
    # SECTION "WebEngine"
    # LABEL "Extensions"
    # PURPOSE "Enables Chromium extensions within certain limits. Currently used for enabling the pdf viewer."
    # AUTODETECT QT_FEATURE_webengine_printing_and_pdf
    # CONDITION QT_FEATURE_webengine_printing_and_pdf
# )
# qt_feature("webengine-webrtc" PRIVATE
    # LABEL "WebRTC"
    # PURPOSE "Provides WebRTC support."
    # AUTODETECT NOT QT_FEATURE_webengine_embedded_build
# )
# qt_feature("webengine-webrtc-pipewire" PRIVATE
    # LABEL "PipeWire over GIO"
    # PURPOSE "Provides PipeWire support in WebRTC using GIO."
    # AUTODETECT false
    # CONDITION QT_FEATURE_webengine_webrtc AND GIO_FOUND
# )
# qt_feature_config("webengine-full-debug-info" QMAKE_PRIVATE_CONFIG
    # NAME "v8base_debug"
# )
# qt_feature_config("webengine-full-debug-info" QMAKE_PRIVATE_CONFIG
    # NAME "webcore_debug"
# )
# qt_configure_add_summary_section(NAME "Qt WebEngineCore")
# qt_configure_add_summary_entry(ARGS "webengine-embedded-build")
# qt_configure_add_summary_entry(ARGS "webengine-full-debug-info")
# qt_configure_add_summary_entry(ARGS "webengine-pepper-plugins")
# qt_configure_add_summary_entry(ARGS "webengine-printing-and-pdf")
# qt_configure_add_summary_entry(ARGS "webengine-proprietary-codecs")
# qt_configure_add_summary_entry(ARGS "webengine-spellchecker")
# qt_configure_add_summary_entry(ARGS "webengine-native-spellchecker")
# qt_configure_add_summary_entry(ARGS "webengine-webrtc")
# qt_configure_add_summary_entry(ARGS "webengine-webrtc-pipewire")
# qt_configure_add_summary_entry(ARGS "webengine-geolocation")
# qt_configure_add_summary_entry(ARGS "webengine-webchannel")
# qt_configure_add_summary_entry(ARGS "webengine-kerberos")
# qt_configure_add_summary_entry(ARGS "webengine-extensions")
# qt_configure_add_summary_entry(
    # ARGS "webengine-ozone-x11"
    # CONDITION UNIX
# )
# qt_configure_add_summary_entry(
    # ARGS "webengine-v8-snapshot-support"
    # CONDITION UNIX AND cross_compile
# )
# qt_configure_add_summary_entry(
    # ARGS "webengine-system-alsa"
    # CONDITION UNIX
# )
# qt_configure_add_summary_entry(
    # ARGS "webengine-system-pulseaudio"
    # CONDITION UNIX
# )
# qt_configure_end_summary_section() # end of "Qt WebEngineCore" section
# qt_configure_add_report_entry(
    # TYPE WARNING
    # MESSAGE "Thumb instruction set is required to build ffmpeg for QtWebEngine."
    # CONDITION LINUX AND QT_FEATURE_webengine_embedded_build AND NOT QT_FEATURE_webengine_system_ffmpeg AND ( TEST_architecture_arch STREQUAL arm ) AND NOT QT_FEATURE_webengine_arm_thumb
# )
# qt_configure_add_report_entry(
    # TYPE WARNING
    # MESSAGE "V8 snapshot cannot be built. Most likely, the 32-bit host compiler does not work. Please make sure you have 32-bit devel environment installed."
    # CONDITION UNIX AND cross_compile AND NOT QT_FEATURE_webengine_v8_snapshot_support
# )
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(GPERF)
vcpkg_find_acquire_program(PYTHON2)

#vcpkg_find_acquire_program(GN) # Qt builds its own internal version
#vcpkg_find_acquire_program(PKGCONFIG)
vcpkg_find_acquire_program(NODEJS)

get_filename_component(GPERF_DIR "${GPERF}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${GPERF_DIR}")
get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${NODEJS_DIR}")
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${PYTHON2_DIR}")

if(WIN32) # WIN32 HOST probably has win_flex and win_bison!
    if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
endif()

### Download third_party modules
vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH_WEBENGINE
    URL git://code.qt.io/qt/qtwebengine-chromium.git
    REF ab55fde35eccd342c0a35913377d9b49b738a423
)

set(BASH "")
if(WIN32)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES bash tar xz coreutils) #wget gzip
    set(BASH "${MSYS_ROOT}/usr/bin/bash.exe" -c)
    string(REPLACE ";$ENV{SystemRoot}\\System32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\System32;" NEWPATH "$ENV{PATH}")
    string(REPLACE ";$ENV{SystemRoot}\\system32;" ";${MSYS_ROOT}/usr/bin;$ENV{SystemRoot}\\system32;" NEWPATH "${NEWPATH}")
    set(ENV{PATH} "${NEWPATH}")
endif()

##### qt_install_submodule
set(qt_plugindir ${QT6_DIRECTORY_PREFIX}plugins)
set(qt_qmldir ${QT6_DIRECTORY_PREFIX}qml)

qt_download_submodule(PATCHES ${${PORT}_PATCHES})
if(QT_UPDATE_VERSION)
    return()
endif()
if(NOT EXISTS "${SOURCE_PATH}/src/3rdparty/chromium")
    file(RENAME "${SOURCE_PATH_WEBENGINE}/chromium" "${SOURCE_PATH}/src/3rdparty/chromium")
endif()
if(NOT EXISTS "${SOURCE_PATH}/src/3rdparty/gn")
    file(RENAME "${SOURCE_PATH_WEBENGINE}/gn" "${SOURCE_PATH}/src/3rdparty/gn")
endif()
# vcpkg_execute_required_process(
    # COMMAND ${BASH} "./update_node_binaries"
    # WORKING_DIRECTORY "${SOURCE_PATH}/src/3rdparty/chromium/third_party/node/"
    # LOGNAME node-update-${TARGET_TRIPLET}
# )

qt_cmake_configure(OPTIONS ${FEATURE_OPTIONS}
                        -DGPerf_EXECUTABLE=${GPERF}
                        -DBISON_EXECUTABLE=${BISON}
                        -DFLEX_EXECUTABLE=${FLEX}
                        #-DGn_EXECUTABLE=${GN}
                        -DPython2_EXECUTABLE=${PYTHON2}
                        -DNodejs_EXECUTABLE=${NODEJS}
                   OPTIONS_DEBUG ${_qis_CONFIGURE_OPTIONS_DEBUG}
                   OPTIONS_RELEASE ${_qis_CONFIGURE_OPTIONS_RELEASE})

vcpkg_install_cmake(ADD_BIN_TO_PATH)

qt_fixup_and_cleanup(TOOL_NAMES ${TOOL_NAMES})

qt_install_copyright("${SOURCE_PATH}")

##### qt_install_submodule
