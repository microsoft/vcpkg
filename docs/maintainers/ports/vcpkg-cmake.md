# vcpkg-cmake

This port contains cmake functions for dealing with a CMake buildsystem.

In the common case, `vcpkg_cmake_configure()` (with appropriate arguments)
followed by `vcpkg_cmake_install()` will be enough to build and install a port.
`vcpkg_cmake_build()` is provided for more complex cases.
