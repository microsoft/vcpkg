set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "canvaspainter" FEATURE_graphs_2d_high_performance_backend
INVERTED_FEATURES
    "canvaspainter" CMAKE_DISABLE_FIND_PACKAGE_Qt6CanvasPainter
    "canvaspainter" CMAKE_DISABLE_FIND_PACKAGE_Qt6CanvasPainterPrivate
)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
