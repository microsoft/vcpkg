# vcpkg_list

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_list.md).

A replacement for CMake's `list()` function, which correctly handles elements
with internal semicolons (in other words, escaped semicolons).
Use `vcpkg_list()` instead of `list()` whenever possible.

```cmake
vcpkg_list(SET <out-var> [<element>...])
vcpkg_list(<COMMAND> <out-var> <list-value> [<other-arguments>...])
```

In addition to all of the commands from `list()`, `vcpkg_list` adds
a `vcpkg_list(SET)` command.
This command takes its arguments, escapes them, and then concatenates
them into a list; this should be used instead of `set()` for setting any
list variable.

Unlike CMake's `list()` function, since this is written in CMake,
we can't make `<list>` an in-out parameter. Therefore, for this
function, the in parameter is split from the out parameter,
and the in parameter is a list value, not a list variable name.
This also means that for sub-commands like `GET`, the out-parameter
is placed _before_ the list, not at the end of the argument list.

Otherwise, the `vcpkg_list()` function is the same as the built-in
`list()` function, with the following restrictions:

- `GET` supports only one index
- `POP_BACK` and `POP_FRONT` do not support getting the value into
  another out variable. Use C++ style `GET` then `POP_(BACK|FRONT)`.
- `FILTER` and `TRANSFORM` are unsupported.

See the [CMake documentation for `list()`](https://cmake.org/cmake/help/latest/command/list.html)
for more information.

## Examples

### Creating a list

```cmake
vcpkg_list(SET foo_param)
if(DEFINED arg_FOO)
    vcpkg_list(SET foo_param FOO "${arg_FOO}")
endif()
```

### Appending to a list

```cmake
set(OPTIONS -DFOO=BAR)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_list(APPEND OPTIONS "${OPTIONS}" -DOS=WINDOWS)
endif()
```

### Popping the end off a list

```cmake
if(NOT list STREQUAL "")
    vcpkg_list(GET end "${list}" -1)
    vcpkg_list(POP_BACK list "${list}")
endif()
```

## Source
[scripts/cmake/vcpkg\_list.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_list.cmake)
