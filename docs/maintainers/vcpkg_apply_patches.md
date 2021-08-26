# vcpkg_apply_patches

**This function has been deprecated in favor of the `PATCHES` argument to [`vcpkg_from_github()`](vcpkg_from_github.md) et al.**

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_apply_patches.md).

Apply a set of patches to a source tree.

```cmake
vcpkg_apply_patches(
    SOURCE_PATH <${SOURCE_PATH}>
    [QUIET]
    PATCHES <patch1.patch>...
)
```

## Source
[scripts/cmake/vcpkg\_apply\_patches.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_apply_patches.cmake)
