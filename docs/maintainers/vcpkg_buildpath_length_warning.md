# vcpkg_buildpath_length_warning

Warns the user if their vcpkg installation path might be too long for the package they're installing.

```cmake
vcpkg_buildpath_length_warning(<N>)
```

`vcpkg_buildpath_length_warning` warns the user if the number of bytes in the
path to `buildtrees` is bigger than `N`. Note that this is simply a warning,
and isn't relied on for correctness.

## Source
[scripts/cmake/vcpkg_buildpath_length_warning.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_buildpath_length_warning.cmake)
