# vcpkg-cmake-config

`vcpkg-cmake-config` provides `vcpkg_cmake_config_fixup()`,
a function which both:

- Fixes common mistakes in port build systems, like using absolute paths
- Merges the debug and release config files.

This function should almost always be used when a port has `*config.cmake` files,
even when the buildsystem of the project is not CMake.
