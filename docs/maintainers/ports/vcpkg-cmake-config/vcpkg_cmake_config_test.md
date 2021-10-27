# vcpkg_cmake_config_test

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-cmake-config/vcpkg_cmake_config_test.md).

Automatically test the correctness of the configuration file exported by cmake

```cmake
vcpkg_cmake_config_test(
    [USAGE <FIND_METHOD>]
    [TARGET_NAMES <TARGETS>...]
    [HEADERS <headername.h>...]
    [FUNCTIONS <function1> ...]
)
```

For most ports, `vcpkg_cmake_config_test` should work without passing any options,
`vcpkg_cmake_config_test` will automatically detect the targets declared in the generated
cmake configuration file which are used in `find_package`, and set the targets to `USAGE`.

`TARGET_NAMES` should use the target name in `target_link_libraries` and support namespace.

For more advanced usage, `vcpkg_cmake_config_test` supports the use of reserved c/c++ code for testing.
Please encapsulate the test code as one or more functions and save them to `vcpkg_test.c` or `vcpkg_test.cpp`,
and pass the name of the system header file that needs to be included into the `HEADERS`.

And, please use option `FUNCTIONS` to pass these test function names into `vcpkg_cmake_config_test`.

More, you can implement the test cmake code by yourself to add additional compilation options
or cmake options by writing them into `vcpkg_test.cmake`.

Please note that `vcpkg_test.cmake` / `vcpkg_test.c` / `vcpkg_test.cpp` must be placed in the same directory
as `portfile.cmake`.

## Examples

* [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake)
* [ptex](https://github.com/Microsoft/vcpkg/blob/master/ports/ptex/portfile.cmake)

## Source
[ports/vcpkg-cmake-config/vcpkg\_cmake\_config\_test.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake-config/vcpkg_cmake_config_test.cmake)
