#Will not build on Windows! 
message(WARNING "This port is just a placeholder until the required wayland libraries have been added into VCPKG! \
            As such the build will most likely fail until your system has the required wayland libraries installed (untested)")

include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation()