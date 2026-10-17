set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "webengine"     CMAKE_REQUIRE_FIND_PACKAGE_Qt6WebEngineCore
    "webengine"     CMAKE_REQUIRE_FIND_PACKAGE_Qt6WebEngineQuick
    "webengine"     FEATURE_webview_webengine_plugin
INVERTED_FEATURES
    "webengine"     CMAKE_DISABLE_FIND_PACKAGE_Qt6WebEngineCore
    "webengine"     CMAKE_DISABLE_FIND_PACKAGE_Qt6WebEngineQuick
)
# The WebView2 backend is not supported by this port yet
list(APPEND FEATURE_OPTIONS -DFEATURE_webview_webview2_plugin=OFF -DCMAKE_DISABLE_FIND_PACKAGE_WebView2=ON)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_MAYBE_UNUSED
                        CMAKE_DISABLE_FIND_PACKAGE_WebView2
                    )
