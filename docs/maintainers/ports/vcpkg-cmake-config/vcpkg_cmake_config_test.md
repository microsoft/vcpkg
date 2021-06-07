# vcpkg_cmake_config_test

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-cmake-config/vcpkg_cmake_config_test.md).

Automatically test the correctness of the configuration file exported by cmake

## Usage
```cmake
vcpkg_cmake_config_test(
    [TARGET_NAME <PORT_NAME>]
    [TARGET_VARS <TARGETS>...]
    [HEADERS <headername.h>...]
    [FUNCTIONS <function1> ...]
)
```

## Parameters
### TARGET_NAME
Specify the main parameters to find the port through find_package
The default value is the prefix of -config.cmake/Config.cmake/Targets.cmake/-targets.cmake

### TARGET_VARS
Specify targets in the configuration file, the value may contain namespace

### HEADERS
Specify the installed header file names (including the relative path)

### FUNCTIONS
Specify the exported function names, do not support namespace currently

## Notes
This function allows to use `vcpkg_test.cmake` / `vcpkg_test.c` / `vcpkg_test.cpp`
that exists in PORT_DIR to test the generated cmake file.
Still work in progress. If there are more cases which can be handled here feel free to add them.

## Examples

* [ptex](https://github.com/Microsoft/vcpkg/blob/master/ports/ptex/portfile.cmake)

## Source
[ports/vcpkg-cmake-config/vcpkg\_cmake\_config\_test.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake-config/vcpkg_cmake_config_test.cmake)
