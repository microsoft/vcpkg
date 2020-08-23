# vcpkg_build_make

Build a linux makefile project.

## Usage:
```cmake
vcpkg_build_make([BUILD_TARGET <target>]
                 [ADD_BIN_TO_PATH]
                 [ENABLE_INSTALL])
                 [LOGFILE_ROOT <logfileroot>])
```

### BUILD_TARGET
The target passed to the make build command (`./make <target>`). If not specified, the 'all' target will
be passed.

### ADD_BIN_TO_PATH
Adds the appropriate Release and Debug `bin\` directories to the path during the build such that executables can run against the in-tree DLLs.

### ENABLE_INSTALL
IF the port supports the install target use vcpkg_install_make() instead of vcpkg_build_make()

### BUILD_TARGET
The target passed to the make build command (`./make <target>`). If not specified, the 'all' target will
be passed.

## Notes:
This command should be preceeded by a call to [`vcpkg_configure_make()`](vcpkg_configure_make.md).
You can use the alias [`vcpkg_install_make()`](vcpkg_configure_make.md) function if your CMake script supports the
"install" target

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)

## Source
[scripts/cmake/vcpkg_build_make.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_build_make.cmake)
