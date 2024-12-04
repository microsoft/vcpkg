set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

vcpkg_download_distfile(android_alooper_26b1629
    URLS "https://github.com/qt/qtsensors/commit/26b1629741d76d36ec1e7364a295081160c0a1bc.diff?full_index=1"
    FILENAME qtsensors-android-26b1629.diff
    SHA512 4f49505ed3d1830e59d118aca2ba348aba54b4d9ded44dfbe444758630566acad96d3108c1e17daecc2d26fc469a9dd2bc1a60cc3380a66e0593ce6b57649cc8
)

set(${PORT}_PATCHES
    "${android_alooper_26b1629}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
INVERTED_FEATURES
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
