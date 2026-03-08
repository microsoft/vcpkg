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
    # Features not yet added in the manifest:
    "vaapi"         CMAKE_DISABLE_FIND_PACKAGE_VAAPI # not in vpckg
)

set(unused "")
if("gstreamer" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer='yes'")
else()
    list(APPEND FEATURE_OPTIONS "-DINPUT_gstreamer='no'")
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
