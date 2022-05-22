# vcpkg_cmake_build

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-cmake/vcpkg_cmake_build.md).

Build a cmake project.

```cmake
vcpkg_cmake_build(
    [TARGET <target>]
    [LOGFILE_BASE <base>]
    [DISABLE_PARALLEL]
    [ADD_BIN_TO_PATH]
)
```

`vcpkg_cmake_build` builds an already-configured cmake project.
You can use the alias [`vcpkg_cmake_install()`] function
if your CMake build system supports the `install` TARGET,
and this is something we recommend doing whenever possible.
Otherwise, you can use `TARGET` to set the target to build.
This function defaults to not passing a target to cmake.

[`vcpkg_cmake_install()`]: vcpkg_cmake_install.md

`LOGFILE_BASE` is used to set the base of the logfile names;
by default, this is `build`, and thus the logfiles end up being something like
`build-x86-windows-dbg.log`; if you use `vcpkg_cmake_install`,
this is set to `install`, so you'll get log names like `install-x86-windows-dbg.log`.

For build systems that are buggy when run in parallel,
using `DISABLE_PARALLEL` will run the build with only one job.

Finally, `ADD_BIN_TO_PATH` adds the appropriate (either release or debug)
`bin/` directories to the path during the build,
such that executables run during the build will be able to access those DLLs.

## Source
[ports/vcpkg-cmake/vcpkg\_cmake\_build.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake/vcpkg_cmake_build.cmake)
