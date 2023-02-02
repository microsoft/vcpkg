# vcpkg_install_nmake

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_install_nmake.md).

Build and install a msvc makefile project.

## Usage:
```cmake
vcpkg_install_nmake(
    SOURCE_PATH <${SOURCE_PATH}>
    [PROJECT_SUBPATH <${SUBPATH}>]
    [PROJECT_NAME <${MAKEFILE_NAME}>]
    [CL_LANGUAGE <language-name>]
    [PREFER_JOM]
    [PRERUN_SHELL <${SHELL_PATH}>]
    [PRERUN_SHELL_DEBUG <${SHELL_PATH}>]
    [PRERUN_SHELL_RELEASE <${SHELL_PATH}>]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
    [TARGET <all>...]
)
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the source files.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PROJECT_SUBPATH
Specifies the sub directory containing the makefile.

### PROJECT_NAME
Specifies the name of the makefile.
Default is `makefile.vc`

### CL_LANGUAGE
Specifies the language for setting up flags in the `_CL_` environment variable.
The default language is `CXX`.
To disable the modification of `_CL_`, use `NONE`.

### PREFER_JOM
Specifies that a parallel build with `jom` should be attempted.
This is useful for faster builds of makefiles which process many independent targets
and which cannot benefit from the `/MP` cl option.
To mitigate issues with concurrency-unaware makefiles, a normal `nmake` build is run after `jom` errors.

### PRERUN_SHELL
Script that needs to be called before build.

### PRERUN_SHELL_DEBUG
Script that needs to be called before debug build.

### PRERUN_SHELL_RELEASE
Script that needs to be called before release build.

### OPTIONS
Additional options passed to the build command.

### OPTIONS_RELEASE
Additional options passed to the build command for the release build. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to the build command for the debug build. These are in addition to `OPTIONS`.

### TARGET
The list of targets passed to the build command.
If not specified, target `all` will be passed.

## Notes:
This command transparently forwards to [`vcpkg_build_nmake()`](vcpkg_build_nmake.md), adding `ENABLE_INSTALL`.

## Examples

* [libspatialite](https://github.com/microsoft/vcpkg/blob/master/ports/libspatialite/portfile.cmake)
* [tcl](https://github.com/microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_install\_nmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_nmake.cmake)
