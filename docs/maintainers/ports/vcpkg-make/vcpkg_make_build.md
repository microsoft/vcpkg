# vcpkg_make_build

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-make/vcpkg_make_build.md).

Build a linux makefile project.

```cmake
vcpkg_make_build(
    [BUILD_TARGET <target>]
    [ADD_BIN_TO_PATH]
    [ENABLE_INSTALL]
    [MAKEFILE <makefileName>]
    [SUBPATH <makefilepath>]
    [DISABLE_PARALLEL]
    [LOGFILE_BASE <logfilebase>]
)
```

`vcpkg_make_build` builds an already-configured make project.
You can use the alias [`vcpkg_make_install()`] function
if the Makefile build system supports the `install` TARGET,
and this is something we recommend doing whenever possible.
Otherwise, you can directly call `vcpkg_make_build` without `ENABLE_INSTALL`.

By default, `vcpkg_make_build` will call the `Makefile` in the build directory
and build all the targets.

If the `Makefile` in another path, please pass the absolute path to `SUBPATH`.
This path is based on the build path.
If the makefile comes from another path or the name is not `Makefile`, please
pass `MAKEFILE` and set the absolute path.
Please pass `BUILD_TARGET` to select the needed targets.

When `ENABLE_INSTALL` is enabled, `vcpkg_make_build` will install all targets
unless `INSTALL_TARGET` is declared as some specific targets.

`LOGFILE_BASE` is used to set the base of the logfile names;
by default, this is `build`, and thus the logfiles end up being something like
`build-x86-windows-dbg.log`; if you use `vcpkg_cmake_install`,
this is set to `install`, so you'll get log names like `install-x86-windows-dbg.log`.

For build systems that are buggy when run in parallel,
using `DISABLE_PARALLEL` will run the build with only one job.

Finally, `ADD_BIN_TO_PATH` adds the appropriate (either release or debug)
`bin/` directories to the path during the build,
such that executables run during the build will be able to access those DLLs.

## Notes:
This command should be preceded by a call to [`vcpkg_make_configure()`](vcpkg_make_configure.md).
You can use the alias [`vcpkgl_make_install()`](vcpkgl_make_install.md) function if your makefile
supports the "install" target.

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)

## Source
[ports/vcpkg-make/vcpkg\_make\_build.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-make/vcpkg_make_build.cmake)
