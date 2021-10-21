# vcpkg_build_nmake

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_build_nmake.md).

Build a msvc makefile project.

## Usage:
```cmake
vcpkg_build_nmake(
    SOURCE_PATH <${SOURCE_PATH}>
    [NO_DEBUG]
    [ENABLE_INSTALL]
    [TARGET <all>]
    [PROJECT_SUBPATH <${SUBPATH}>]
    [PROJECT_NAME <${MAKEFILE_NAME}>]
    [PRERUN_SHELL <${SHELL_PATH}>]
    [PRERUN_SHELL_DEBUG <${SHELL_PATH}>]
    [PRERUN_SHELL_RELEASE <${SHELL_PATH}>]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
    [TARGET <target>])
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the source files.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PROJECT_SUBPATH
Specifies the sub directory containing the `makefile.vc`/`makefile.mak`/`makefile.msvc` or other msvc makefile.

### PROJECT_NAME
Specifies the name of msvc makefile name.
Default is `makefile.vc`

### NO_DEBUG
This port doesn't support debug mode.

### ENABLE_INSTALL
Install binaries after build.

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

### TARGET
The target passed to the nmake build command (`nmake/nmake install`). If not specified, no target will
be passed.

### ADD_BIN_TO_PATH
Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.

## Notes:
You can use the alias [`vcpkg_install_nmake()`](vcpkg_install_nmake.md) function if your makefile supports the
"install" target

## Examples

* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_build\_nmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_build_nmake.cmake)
