include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(
    RUNTIME_FOR_TOOLS
        Qt5QuickControls2   # for qt5-tools
        Qt5QuickTemplates2  # for qt5-tools
)
