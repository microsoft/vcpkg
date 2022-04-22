# vcpkg_buildpath_length_warning

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_buildpath_length_warning.md).

Warns the user if their vcpkg installation path might be too long for the package they're installing.

```cmake
vcpkg_buildpath_length_warning(<N>)
```

`vcpkg_buildpath_length_warning` warns the user if the number of bytes in the
path to `buildtrees` is bigger than `N`. Note that this is simply a warning,
and isn't relied on for correctness.

## Source
[scripts/cmake/vcpkg\_buildpath\_length\_warning.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_buildpath_length_warning.cmake)
