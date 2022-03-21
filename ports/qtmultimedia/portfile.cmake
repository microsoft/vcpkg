set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES fix_windows_header_include.patch
                    remove_unistd.patch
                    )

#Maybe TODO: ALSA + PulseAudio? (Missing Ports) -> check ALSA since it was added

# qt_find_package(ALSA PROVIDED_TARGETS ALSA::ALSA MODULE_NAME multimedia QMAKE_LIB alsa)
# qt_find_package(AVFoundation PROVIDED_TARGETS AVFoundation::AVFoundation MODULE_NAME multimedia QMAKE_LIB avfoundation)
# qt_find_package(WrapPulseAudio PROVIDED_TARGETS WrapPulseAudio::WrapPulseAudio MODULE_NAME multimedia QMAKE_LIB pulseaudio)
# qt_find_package(WMF PROVIDED_TARGETS WMF::WMF MODULE_NAME multimedia QMAKE_LIB wmf)

# qt_configure_add_summary_section(NAME "Qt Multimedia")
# qt_configure_add_summary_entry(ARGS "alsa")
# qt_configure_add_summary_entry(ARGS "gstreamer_1_0")
# qt_configure_add_summary_entry(ARGS "linux_v4l")
# qt_configure_add_summary_entry(ARGS "pulseaudio")
# qt_configure_add_summary_entry(ARGS "mmrenderer")
# qt_configure_add_summary_entry(ARGS "avfoundation")
# qt_configure_add_summary_entry(ARGS "wmf")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
    "widgets"       CMAKE_REQUIRE_FIND_PACKAGE_Qt6Widgets
    #"gstreamer"     CMAKE_REQUIRE_FIND_PACKAGE_GStreamer
INVERTED_FEATURES
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    "widgets"       CMAKE_DISABLE_FIND_PACKAGE_Qt6Widgets
    "gstreamer"     CMAKE_DISABLE_FIND_PACKAGE_GStreamer
)

if("gstreamer" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer='yes'")
else()
    list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer='no'")
endif()

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND FEATURE_OPTIONS "-DFEATURE_alsa=ON")
     list(APPEND FEATURE_OPTIONS "-DCMAKE_REQUIRE_FIND_PACKAGE_ALSA=ON")
else()
    list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_ALSA=ON")
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
