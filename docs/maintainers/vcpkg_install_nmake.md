# vcpkg_install_nmake

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_install_nmake.md).

Build and install a msvc makefile project.

## Usage:
```cmake
vcpkg_install_nmake(
    SOURCE_PATH <${SOURCE_PATH}>
    [NO_DEBUG]
    [TARGET <all>]
    PROJECT_SUBPATH <${SUBPATH}>
    PROJECT_NAME <${MAKEFILE_NAME}>
    [PRERUN_SHELL <${SHELL_PATH}>]
    [PRERUN_SHELL_DEBUG <${SHELL_PATH}>]
    [PRERUN_SHELL_RELEASE <${SHELL_PATH}>]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the source files.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PROJECT_SUBPATH
Specifies the sub directory containing the `makefile.vc`/`makefile.mak`/`makefile.msvc` or other msvc makefile.

### PROJECT_NAME
Specifies the name of msvc makefile name.
Default is makefile.vc

### NO_DEBUG
This port doesn't support debug mode.

### PRERUN_SHELL
Script that needs to be called before build

### PRERUN_SHELL_DEBUG
Script that needs to be called before debug build

### PRERUN_SHELL_RELEASE
Script that needs to be called before release build

### OPTIONS
Additional options passed to generate during the generation.

### OPTIONS_RELEASE
Additional options passed to generate during the Release generation. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to generate during the Debug generation. These are in addition to `OPTIONS`.

## Parameters:
See [`vcpkg_build_nmake()`](vcpkg_build_nmake.md).

## Notes:
This command transparently forwards to [`vcpkg_build_nmake()`](vcpkg_build_nmake.md), adding `ENABLE_INSTALL`

## Examples

* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_install\_nmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_nmake.cmake)
