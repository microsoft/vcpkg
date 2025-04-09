message(STATUS "${PORT} has a spurious failure in which it is unable to create a parent directory! Just retry.")
include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation(PATCHES missing-include.patch disable-enum-warning.patch)
