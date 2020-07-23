include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)

# Disable parallel build
set(VCPKG_CONCURRENCY 1)
qt_submodule_installation()