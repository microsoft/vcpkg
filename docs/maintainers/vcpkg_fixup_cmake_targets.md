# vcpkg_fixup_cmake_targets

**This function has been deprecated in favor of [`vcpkg_cmake_config_fixup`](ports/vcpkg-cmake-config/vcpkg_cmake_config_fixup.md) from the vcpkg-cmake-config port.**

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_fixup_cmake_targets.md).

Merge release and debug CMake targets and configs to support multiconfig generators.

Additionally corrects common issues with targets, such as absolute paths and incorrectly placed binaries.

## Usage
```cmake
vcpkg_fixup_cmake_targets([CONFIG_PATH <share/${PORT}>] 
                          [TARGET_PATH <share/${PORT}>] 
                          [TOOLS_PATH <tools/${PORT}>]
                          [DO_NOT_DELETE_PARENT_CONFIG_PATH])
```

## Parameters

### CONFIG_PATH
Subpath currently containing `*.cmake` files subdirectory (like `lib/cmake/${PORT}`). Should be relative to `${CURRENT_PACKAGES_DIR}`.

Defaults to `share/${PORT}`.

### TARGET_PATH
Subpath to which the above `*.cmake` files should be moved. Should be relative to `${CURRENT_PACKAGES_DIR}`.
This needs to be specified if the port name differs from the `find_package()` name.

Defaults to `share/${PORT}`.

### DO_NOT_DELETE_PARENT_CONFIG_PATH
By default the parent directory of CONFIG_PATH is removed if it is named "cmake".
Passing this option disable such behavior, as it is convenient for ports that install
more than one CMake package configuration file.

### NO_PREFIX_CORRECTION
Disables the correction of_IMPORT_PREFIX done by vcpkg due to moving the targets.
Currently the correction does not take into account how the files are moved and applies
I rather simply correction which in some cases will yield the wrong results.

### TOOLS_PATH
Define the base path to tools. Default: `tools/<PORT>`

## Notes
Transform all `/debug/<CONFIG_PATH>/*targets-debug.cmake` files and move them to `/<TARGET_PATH>`.
Removes all `/debug/<CONFIG_PATH>/*targets.cmake` and `/debug/<CONFIG_PATH>/*config.cmake`.

Transform all references matching `/bin/*.exe` to `/${TOOLS_PATH}/*.exe` on Windows.
Transform all references matching `/bin/*` to `/${TOOLS_PATH}/*`  on other platforms.

Fix `${_IMPORT_PREFIX}` in auto generated targets to be one folder deeper.
Replace `${CURRENT_INSTALLED_DIR}` with `${_IMPORT_PREFIX}` in configs and targets.

## Examples

* [concurrentqueue](https://github.com/Microsoft/vcpkg/blob/master/ports/concurrentqueue/portfile.cmake)
* [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake)
* [nlohmann-json](https://github.com/Microsoft/vcpkg/blob/master/ports/nlohmann-json/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_fixup\_cmake\_targets.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_fixup_cmake_targets.cmake)
