# vcpkg_host_path_list

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_host_path_list.md).

Modify a host path list variable (PATH, INCLUDE, LIBPATH, etc.)

```cmake
vcpkg_host_path_list(PREPEND <list-var> [<path>...])
vcpkg_host_path_list(APPEND <list-var> [<path>...])
vcpkg_host_path_list(SET <list-var> [<path>...])
```

`<list-var>` may be either a regular variable name, or `ENV{variable-name}`,
in which case `vcpkg_host_path_list` will modify the environment.

`vcpkg_host_path_list` adds all of the paths passed to it to `<list-var>`;
`PREPEND` puts them before the existing list, so that they are searched first;
`APPEND` places them after the existing list,
so they would be searched after the paths which are already in the variable,
and `SET` replaces the value of the existing list.

For all of `APPEND`, `PREPEND`, and `SET`,
the paths are added (and thus searched) in the order received.

If no paths are passed to `APPEND` or `PREPEND`, nothing will be done;
for `SET`, the variable will be set to the empty string.

## Source
[scripts/cmake/vcpkg\_host\_path\_list.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_host_path_list.cmake)
