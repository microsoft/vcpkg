set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES
    devendor-poly2tri.patch)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
INVERTED_FEATURES
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
)

list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_Gypsy=ON"
                            "-DCMAKE_DISABLE_FIND_PACKAGE_Gconf=ON"
)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
