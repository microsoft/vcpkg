# vcpkg_add_to_path

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_add_to_path.md).

Add a directory or directories to the PATH environment variable

```cmake
vcpkg_add_to_path([PREPEND] [<path>...])
```

`vcpkg_add_to_path` adds all of the paths passed to it to the PATH environment variable.
If PREPEND is passed, then those paths are prepended to the PATH environment variable,
so that they are searched first; otherwise, those paths are appended, so they are
searched after the paths which are already in the environment variable.

The paths are added in the order received, so that the first path is always searched
before a later path.

If no paths are passed, then nothing will be done.

## Examples:
* [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake#L75)
* [folly](https://github.com/Microsoft/vcpkg/blob/master/ports/folly/portfile.cmake#L15)
* [z3](https://github.com/Microsoft/vcpkg/blob/master/ports/z3/portfile.cmake#L13)

## Source
[scripts/cmake/vcpkg\_add\_to\_path.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_add_to_path.cmake)
