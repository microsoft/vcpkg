# vcpkg-cmake-config

`vcpkg-cmake-config` provides `vcpkg_cmake_config_fixup()` and `vcpkg_cmake_config_test()`.
The first function:

- Fixes common mistakes in port build systems, like using absolute paths
- Merges the debug and release config files.

This function should almost always be used when a port has `*config.cmake` files,
even when the buildsystem of the project is not CMake.

The latter function tests the generated cmake config files;
in general, any port that generates `*[Cc]onfig.cmake` should call this
function to check whether the generated configuration is correct,
after calling `vcpkg_cmake_config_fixup()`.
