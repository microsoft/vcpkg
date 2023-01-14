# vcpkg_clean_executables_in_bin

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_clean_executables_in_bin.md).

Remove specified executables found in `${CURRENT_PACKAGES_DIR}/bin` and `${CURRENT_PACKAGES_DIR}/debug/bin`. If, after all specified executables have been removed, and the `bin` and `debug/bin` directories are empty, then also delete `bin` and `debug/bin` directories.

## Usage
```cmake
vcpkg_clean_executables_in_bin(
    FILE_NAMES <file1>...
)
```

## Parameters
### FILE_NAMES
A list of executable filenames without extension.

## Notes
Generally, there is no need to call this function manually. Instead, pass an extra `AUTO_CLEAN` argument when calling `vcpkg_copy_tools`.

## Examples
* [czmq](https://github.com/microsoft/vcpkg/blob/master/ports/czmq/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_clean\_executables\_in\_bin.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_clean_executables_in_bin.cmake)
