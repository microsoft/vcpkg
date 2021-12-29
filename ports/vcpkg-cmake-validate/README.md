# vcpkg-cmake-validate

`vcpkg-cmake-validate` provides `vcpkg_cmake_validate()`,
a function which tests the correctness of the cmake package configuration
established by a find_package() call.

This function should almost always be used when a port supports
`find_package()`, even when the buildsystem of the project is not CMake.
