# vcpkg_configure_gn

**This function has been deprecated in favor of [`vcpkg_gn_configure`](ports/vcpkg-gn/vcpkg_gn_configure.md) from the vcpkg-gn port.**

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_configure_gn.md).

Generate Ninja (GN) targets

## Usage:
```cmake
vcpkg_configure_gn(
    SOURCE_PATH <SOURCE_PATH>
    [OPTIONS <OPTIONS>]
    [OPTIONS_DEBUG <OPTIONS_DEBUG>]
    [OPTIONS_RELEASE <OPTIONS_RELEASE>]
)
```

## Parameters:
### SOURCE_PATH (required)
The path to the GN project.

### OPTIONS
Options to be passed to both the debug and release targets.
Note: Must be provided as a space-separated string.

### OPTIONS_DEBUG (space-separated string)
Options to be passed to the debug target.

### OPTIONS_RELEASE (space-separated string)
Options to be passed to the release target.

## Source
[scripts/cmake/vcpkg\_configure\_gn.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_gn.cmake)
