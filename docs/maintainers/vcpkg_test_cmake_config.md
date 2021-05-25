# vcpkg_test_cmake_config

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_test_cmake_config.md).

Automatically test the correctness of the configuration file exported by cmake

## Usage
```cmake
vcpkg_test_cmake_config(
    [TARGET_NAME <PORT_NAME>]
    [TARGET_VARS <TARGETS>...]
    [SKIP_CHECK]
)
```

## Parameters
### TARGET_NAME
Specify the main parameters to find the port through find_package
The default value is the prefix of -config.cmake/Config.cmake/Targets.cmake/-targets.cmake

### TARGET_VARS
Specify targets in the configuration file, the value may contain namespace

## Notes
Still work in progress. If there are more cases which can be handled here feel free to add them

## Examples

* [ptex](https://github.com/Microsoft/vcpkg/blob/master/ports/ptex/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_test\_cmake\_config.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_test_cmake_config.cmake)
