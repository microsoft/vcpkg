# vcpkg_make_configure

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-make/vcpkg_make_configure.md).

Configure a Makefile buildsystem.

```cmake
vcpkg_make_configure(
    SOURCE_PATH <${source_path}>
    [USE_WRAPPERS]
    [DETERMINE_BUILD_TRIPLET]
    [BUILD_TRIPLET "--host=x64 --build=i686-unknown-pc"]
    [NO_ADDITIONAL_PATHS]
    [CONFIG_DEPENDENT_ENVIRONMENT <some_var>...]
    [CONFIGURE_ENVIRONMENT_VARIABLES <some_envvar>...]
    [ADD_BIN_TO_PATH]
    [NO_DEBUG]
    [SKIP_CONFIGURE]
    [PROJECT_SUBPATH <${proj_subpath}>]
    [PRERUN_SHELL <${shell_path}>]
    [OPTIONS <--use_this_in_all_builds=1>...]
    [OPTIONS_RELEASE <--optimize=1>...]
    [OPTIONS_DEBUG <--debuggable=1>...]
)
```

`vcpkg_make_configure` configures a Makefile build system for use with
`vcpkg_make_buildsystem_build` and `vcpkg_make_buildsystem_install`.
`source-path` is where the source is located; by convention,
this is usually `${SOURCE_PATH}`, which is set by one of the `vcpkg_from_*` functions.
Use `PROJECT_SUBPATH` if `configure`/`configure.ac` is elsewhere in the source directory.
This function configures the build system for both Debug and Release builds by default,
assuming that `VCPKG_BUILD_TYPE` is not set; if it is, then it will only configure for
that build type. All default build configurations will be obtained from cmake
configuration through `z_vcpkg_get_cmake_vars`.

Use the `OPTIONS` argument to set the configure settings for both release and debug,
and use `OPTIONS_RELEASE` and `OPTIONS_DEBUG` to set the configure settings for
release only and debug only respectively.

`vcpkg_make_configure` uses [mingw] as its build system on Windows and uses [GNU Make]
on non-Windows.
Do not use for batch files which simply call autoconf or configure.

[mingw]: https://www.mingw-w64.org/
[GNU Make]: https://www.gnu.org/software/make/

By default, `vcpkg_make_configure` uses the current architecture as the --build/--target/--host.
For cross-platform construction, use `DETERMINE_BUILD_TRIPLET` to adapt to the host platform.
You can also use `BUILD_TRIPLET` to specify --build/--target/--host, this option will overwrite
`VCPKG_MAKE_BUILD_TRIPLET` globally.

For some libraries, additional scripts need to be called before configure, pass `PRERUN_SHELL`
and set the script relative path.

Use `ADD_BIN_TO_PATH` during configuration to add the appropriate Release and Debug `bin\`
directories to the path so that the executable file can run against the in-tree DLL.
Use `NO_ADDITIONAL_PATHS `to not add additional paths except `--prefix` to configure.

Use `USE_WRAPPERS` to use autotools ar-lib and compile wrappers when building Windows.

Use `DISABLE_VERBOSE_FLAGS` to not pass '--disable-silent-rules --verbose' to configure.

## Notes
This command supplies many common arguments to configure. To see the full list, examine the source.

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)

## Source
[ports/vcpkg-make/vcpkg\_make\_configure.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-make/vcpkg_make_configure.cmake)
