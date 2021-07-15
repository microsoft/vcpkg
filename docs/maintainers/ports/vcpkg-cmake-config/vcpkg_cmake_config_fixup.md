# vcpkg_cmake_config_fixup

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-cmake-config/vcpkg_cmake_config_fixup.md).

Merge release and debug CMake targets and configs to support multiconfig generators.

Additionally corrects common issues with targets, such as absolute paths and incorrectly placed binaries.

```cmake
vcpkg_cmake_config_fixup(
    [PACKAGE_NAME <name>]
    [CONFIG_PATH <config-directory>]
    [DO_NOT_DELETE_PARENT_CONFIG_PATH]
    [NO_PREFIX_CORRECTION]
)
```

For many ports, `vcpkg_cmake_config_fixup()` on its own should work,
as `PACKAGE_NAME` defaults to `${PORT}` and `CONFIG_PATH` defaults to `share/${PACKAGE_NAME}`.
For ports where the package name passed to `find_package` is distinct from the port name,
`PACKAGE_NAME` should be changed to be that name instead.
For ports where the directory of the `*config.cmake` files cannot be set,
use the `CONFIG_PATH` to change the directory where the files come from.

By default the parent directory of CONFIG_PATH is removed if it is named "cmake".
Passing the `DO_NOT_DELETE_PARENT_CONFIG_PATH` option disable such behavior,
as it is convenient for ports that install
more than one CMake package configuration file.

The `NO_PREFIX_CORRECTION` option disables the correction of `_IMPORT_PREFIX`
done by vcpkg due to moving the config files.
Currently the correction does not take into account how the files are moved,
and applies a rather simply correction which in some cases will yield the wrong results.

## How it Works

1. Moves `/debug/<CONFIG_PATH>/*targets-debug.cmake` to `/share/${PACKAGE_NAME}`.
2. Removes `/debug/<CONFIG_PATH>/*config.cmake`.
3. Transform all references matching `/bin/*.exe` to `/tools/<port>/*.exe` on Windows.
4. Transform all references matching `/bin/*` to `/tools/<port>/*` on other platforms.
5. Fixes `${_IMPORT_PREFIX}` in auto generated targets.
6. Replace `${CURRENT_INSTALLED_DIR}` with `${_IMPORT_PREFIX}` in configs and targets.

## Examples

* [concurrentqueue](https://github.com/Microsoft/vcpkg/blob/master/ports/concurrentqueue/portfile.cmake)
* [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake)
* [nlohmann-json](https://github.com/Microsoft/vcpkg/blob/master/ports/nlohmann-json/portfile.cmake)

## Source
[ports/vcpkg-cmake-config/vcpkg\_cmake\_config\_fixup.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake-config/vcpkg_cmake_config_fixup.cmake)
