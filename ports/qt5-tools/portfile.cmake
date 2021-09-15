include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)

qt_submodule_installation(PATCHES
    icudt-debug-suffix.patch # https://bugreports.qt.io/browse/QTBUG-87677
)
