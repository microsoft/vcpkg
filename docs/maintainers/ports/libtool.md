# libtool

**Experimental: will change or be removed at any time**

Port `libtool` provides `x_vcpkg_update_libtool()`, a function which updates
libtool (`ltmain.sh`) in source packages.

For ports which recreate the build system (using the `AUTOCONFIG` option to
`vcpkg_configure_make`), this port makes `libtool` and `libtoolize` available
via the system's `PATH` environment variable and via cmake cache variables
`LIBTOOL_EXECUTABLE` and `LIBTOOLIZE_EXECUTABLE`. (Note that these programs are
bash scripts.) It also updates environment variable `ACLOCAL_PATH`.
