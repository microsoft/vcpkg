set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES
    static_find_modules.patch
    remove-static-ssl-stub.patch
    ffmpeg-compile-def.patch
    ffmpeg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
    "widgets"       CMAKE_REQUIRE_FIND_PACKAGE_Qt6Widgets
INVERTED_FEATURES
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    "widgets"       CMAKE_DISABLE_FIND_PACKAGE_Qt6Widgets
    "gstreamer"     CMAKE_DISABLE_FIND_PACKAGE_GStreamer
    "ffmpeg"        CMAKE_DISABLE_FIND_PACKAGE_FFmpeg
    # Features not yet added in the manifest:
    "vaapi"         CMAKE_DISABLE_FIND_PACKAGE_VAAPI # not in vpckg
)

set(unused "")
if("gstreamer" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer='yes'")
else()
    list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer='no'")
    list(APPEND unused INPUT_gstreamer_gl INPUT_gstreamer_photography)
endif()
list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer_gl='no'")
list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer_photography='no'")

if("ffmpeg" IN_LIST FEATURES)
    # Note: Requires pulsadio on linux and wmfsdk on windows
    list(APPEND FEATURE_OPTIONS "-DINPUT_ffmpeg='yes'")
    if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_ANDROID)
        list(APPEND FEATURE_OPTIONS "-DINPUT_pulseaudio='no'")
    else()
        list(APPEND FEATURE_OPTIONS "-DINPUT_pulseaudio='yes'")
    endif()
else()
    list(APPEND FEATURE_OPTIONS "-DINPUT_ffmpeg='no'")
    list(APPEND FEATURE_OPTIONS "-DINPUT_pulseaudio='no'")
endif()

# alsa is not ready
if(NOT "ffmpeg" IN_LIST FEATURES AND NOT "gstreamer" IN_LIST FEATURES AND VCPKG_TARGET_IS_LINUX)
  #list(APPEND FEATURE_OPTIONS "-DFEATURE_alsa=ON") # alsa is experimental so don't activate it (also missing the dep on it.)
  message(FATAL_ERROR "You need to activate at least one backend.")
else()
  list(APPEND FEATURE_OPTIONS "-DFEATURE_alsa=OFF")
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                     CONFIGURE_OPTIONS_MAYBE_UNUSED ${unused}
                    )

if("gstreamer" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/Qt6Multimedia/Qt6QGstreamerMediaPluginDependencies.cmake" "GStreamer\;FALSE\;\;\;;GStreamer\;FALSE\;\;App\;;GStreamer\;FALSE\;\;\;Gl" "GStreamer\;FALSE\;\;\;;GStreamer\;FALSE\;\;App\;;GStreamer\;FALSE\;\;\;Gl;EGL\;FALSE\;\;\;" IGNORE_UNCHANGED)
endif()
