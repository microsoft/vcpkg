include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)

qt_submodule_installation(
    PATCHES
        "fix-pkgconfig-qt5uiplugin-not-found.patch"
    RUNTIME_FOR_TOOLS
        Qt5Designer             # for qt5-tools
        Qt5DesignerComponents   # for qt5-tools
        Qt5Help                 # for qt5-tools
)
