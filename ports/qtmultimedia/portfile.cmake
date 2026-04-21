set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES
    static_find_modules.patch
    remove-static-ssl-stub.patch
    ffmpeg-compile-def-and-devendor-signalsmith-stretch.patch
    ffmpeg.patch
    ae41d3e-ffmpeg8.diff
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
    "pipewire"      CMAKE_DISABLE_FIND_PACKAGE_PipeWire
    "pulseaudio"    CMAKE_DISABLE_FIND_PACKAGE_WrapPulseAudio
    # Features not yet added in the manifest:
    "vaapi"         CMAKE_DISABLE_FIND_PACKAGE_VAAPI # not in vpckg
    #"mmrenderer"    CMAKE_DISABLE_FIND_PACKAGE_MMRenderer # OS = QNX ?
    #"mmrenderer"    CMAKE_DISABLE_FIND_PACKAGE_MMRendererCore
)

list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_ALSA=ON")

# Force all gstreamer extra features to off to not poison the cache
# since enabling them is done depening on how gstreamer was built
list(APPEND FEATURE_OPTIONS "-DFEATURE_gstreamer_gl=OFF")
list(APPEND FEATURE_OPTIONS "-DFEATURE_gstreamer_gl_wayland=OFF")
list(APPEND FEATURE_OPTIONS "-DFEATURE_gstreamer_gl_egl=OFF")
list(APPEND FEATURE_OPTIONS "-DFEATURE_gstreamer_gl_x11=OFF")
list(APPEND FEATURE_OPTIONS "-DFEATURE_gstreamer_photography=OFF")

set(unused "")
if("gstreamer" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer='yes'")
else()
    list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer='no'")
endif()

if("pipewire" IN_LIST FEATURES)
    # This also requires QT_FEATURE_library from qtbase but
    # that is not exposed by vcpkg via a feature
    list(APPEND FEATURE_OPTIONS "-DINPUT_pipewire='yes'")
else()
    list(APPEND FEATURE_OPTIONS "-DINPUT_pipewire='no'")
endif()

if("ffmpeg" IN_LIST FEATURES)
    # Note: Requires pulsadio on linux and wmfsdk on windows
    list(APPEND FEATURE_OPTIONS "-DINPUT_ffmpeg='yes'")
else()
    list(APPEND FEATURE_OPTIONS "-DINPUT_ffmpeg='no'")
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
