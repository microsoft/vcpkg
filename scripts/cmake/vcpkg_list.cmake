#[===[.md:
# vcpkg_list

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
#]===]

function(vcpkg_list operation out_var)
    if(operation STREQUAL "SET")
        z_vcpkg_function_arguments(args 2)
        set("${out_var}" "${args}" PARENT_SCOPE)
        return()
    endif()

    # Normal reading functions
    if(operation STREQUAL "LENGTH")
        if(NOT ARGC EQUAL "3")
            message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires three arguments.")
        endif()
        list(LENGTH lst out)
        set("${out_var}" "${out}" PARENT_SCOPE)
        return()
    endif()
    if(operation MATCHES "^(GET|JOIN|FIND)$")
        if(NOT ARGC EQUAL "4")
            message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires three arguments.")
        endif()
        list("${operation}" lst "${ARGV3}" out)
        set("${out_var}" "${out}" PARENT_SCOPE)
        return()
    endif()
    if(operation STREQUAL "SUBLIST")
        if(NOT ARGC EQUAL "5")
            message(FATAL_ERROR "vcpkg_list sub-command SUBLIST requires four arguments.")
        endif()
        # sublist removes a `\`, so add an additional backslash
        string(REPLACE [[\;]] [[\\;]] lst "${lst}")
        list(SUBLIST lst "${ARGV3}" "${ARGV4}" out)
        set("${out_var}" "${out}" PARENT_SCOPE)
        return()
    endif()

    if(ARGC LESS "3")
        message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires at least two arguments.")
    endif()
    set(lst "${ARGV2}")

    # modification
    z_vcpkg_function_arguments(args 3)

    # APPEND and PREPEND don't need this fixup
    if(NOT operation MATCHES "^(APPEND|PREPEND)$")
        # all the other operations _do_ need it (see comment in SUBLIST)
        string(REPLACE [[\;]] [[\\;]] lst "${lst}")
    endif()
    # inserters and remove_item require the arguments to be fixed up as well
    if(operation MATCHES "^(APPEND|PREPEND|INSERT|REMOVE_ITEM)$")
        string(REPLACE [[\;]] [[\\;]] args "${args}")
    elseif(operation MATCHES "^(POP_BACK|POP_FRONT)$" AND NOT ARGC EQUAL 3)
        # getting a value from PUSH_BACK/POP_BACK is unsupported
        message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires two arguments.")
    elseif(operation MATCHES "^(FILTER|TRANSFORM)$")
        # regexes are hard
        message(FATAL_ERROR "vcpkg_list sub-command ${operation} is currently unsupported.")
    endif()

    list("${operation}" lst ${args})
    set("${out_var}" "${lst}" PARENT_SCOPE)
endfunction()
