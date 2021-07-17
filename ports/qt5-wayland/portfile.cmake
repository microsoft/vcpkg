#Will not build on Windows!
message(WARNING "This port is just a placeholder until the required wayland libraries have been added into VCPKG! \
            As such the build will most likely fail until your system has the required wayland libraries installed (untested)")
message(WARNING "qtwayland requires libwayland-dev from your system package manager. You can install it with
sudo apt install libwayland-dev
on Ubuntu systems.")
include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)
qt_submodule_installation()
