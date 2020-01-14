# vcpkg_build_make

Build a linux makefile project.

## Usage:
```cmake
vcpkg_build_make(
    [MAKE_OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [MAKE_OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [MAKE_OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
    [MAKE_INSTALL_OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [MAKE_INSTALL_OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [MAKE_INSTALL_OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
    [TARGET <target>]
)
```

## Parameters:
### MAKE_OPTIONS
Additional options passed to make during the generation.

### MAKE_OPTIONS_RELEASE
Additional options passed to make during the Release generation. These are in addition to `MAKE_OPTIONS`.

### MAKE_OPTIONS_DEBUG
Additional options passed to make during the Debug generation. These are in addition to `MAKE_OPTIONS`.

### MAKE_INSTALL_OPTIONS
Additional options passed to make during the installation.

### MAKE_INSTALL_OPTIONS_RELEASE
Additional options passed to make during the Release installation. These are in addition to `MAKE_INSTALL_OPTIONS`.

### MAKE_INSTALL_OPTIONS_DEBUG
Additional options passed to make during the Debug installation. These are in addition to `MAKE_INSTALL_OPTIONS`.

### TARGET
The target passed to the configure/make build command (`./configure/make/make install`). If not specified, no target will
be passed.

### ADD_BIN_TO_PATH
Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.

## Notes:
This command should be preceeded by a call to [`vcpkg_configure_make()`](vcpkg_configure_make.md).
You can use the alias [`vcpkg_install_make()`](vcpkg_install_make.md) function if your CMake script supports the
"install" target

## Examples

* [luajit](https://github.com/Microsoft/vcpkg/blob/master/ports/luajit/portfile.cmake)
* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)

## Source
[scripts/cmake/vcpkg_build_make.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_build_make.cmake)
