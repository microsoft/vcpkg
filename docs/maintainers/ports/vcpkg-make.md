# vcpkg-make

This port contains make functions for dealing with a Makefile buildsystem.

In the common case, `vcpkg_make_configure()` (with appropriate arguments)
followed by `vcpkg_make_install()` will be enough to build and install a port.
`vcpkg_make_build()` is provided for more complex cases.
