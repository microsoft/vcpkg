# vcpkg_check_linkage

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_check_linkage.md).

Asserts the available library and CRT linkage options for the port.

## Usage
```cmake
vcpkg_check_linkage(
    [ONLY_STATIC_LIBRARY | ONLY_DYNAMIC_LIBRARY]
    [ONLY_STATIC_CRT | ONLY_DYNAMIC_CRT]
)
```

## Parameters
### ONLY_STATIC_LIBRARY
Indicates that this port can only be built with static library linkage.

Note: If the user requested a dynamic build ONLY_STATIC_LIBRARY will result in a note being printed, not a fatal error.

### ONLY_DYNAMIC_LIBRARY
Indicates that this port can only be built with dynamic/shared library linkage.

### ONLY_STATIC_CRT
Indicates that this port can only be built with static CRT linkage.

### ONLY_DYNAMIC_CRT
Indicates that this port can only be built with dynamic/shared CRT linkage.

## Notes
This command will either alter the settings for `VCPKG_LIBRARY_LINKAGE` or fail, depending on what was requested by the user versus what the library supports.

## Examples

* [abseil](https://github.com/Microsoft/vcpkg/blob/master/ports/abseil/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_check\_linkage.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_check_linkage.cmake)
