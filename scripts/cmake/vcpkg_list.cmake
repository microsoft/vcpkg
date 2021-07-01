#[===[.md:
# vcpkg_list

A replacement for CMake's `list()` function, which correctly handles elements
with internal semicolons (in other words, escaped semicolons).
Use `vcpkg_list()` instead of `list()` whenever possible.

```cmake
vcpkg_list(SET <out-var> [<element>...])
vcpkg_list(<COMMAND> <list-var> [<other-arguments>...])
```

In addition to all of the commands from `list()`, `vcpkg_list` adds
a `vcpkg_list(SET)` command.
This command takes its arguments, escapes them, and then concatenates
them into a list; this should be used instead of `set()` for setting any
list variable.

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
    vcpkg_list(APPEND OPTIONS "-DOS=WINDOWS;FOO")
endif()
```

### Popping the end off a list

```cmake
if(NOT list STREQUAL "")
    vcpkg_list(GET list end -1)
    vcpkg_list(POP_BACK list)
endif()
```
#]===]

macro(z_vcpkg_list_escape_once_more lst)
    string(REPLACE [[\;]] [[\\;]] "${lst}" "${${lst}}")
endmacro()

function(vcpkg_list)
    # NOTE: as this function replaces an existing CMake command,
    # it does not use cmake_parse_arguments

    # vcpkg_list(<operation> <list_var> ...)
    #            A0          A1

    if(ARGC LESS "2")
        message(FATAL_ERROR "vcpkg_list requires at least two arguments.")
    endif()

    if(ARGV1 MATCHES "^ARGV([0-9]*)$|^ARG[CN]$|^CMAKE_CURRENT_FUNCTION")
        message(FATAL_ERROR "vcpkg_list does not support the list_var being ${ARGV1}.
    Please use a different variable name.")
    endif()

    set(list "${${ARGV1}}")
    set(operation "${ARGV0}")
    set(list_var "${ARGV1}")

    if(operation STREQUAL "SET")
        z_vcpkg_function_arguments(args 2)
        set("${list_var}" "${args}" PARENT_SCOPE)
        return()
    endif()

    # Normal reading functions
    if(operation STREQUAL "LENGTH")
        # vcpkg_list(LENGTH <list-var> <out-var>)
        #            A0     A1         A2
        if(NOT ARGC EQUAL "3")
            message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires two arguments.")
        endif()
        list(LENGTH list out)
        set("${ARGV2}" "${out}" PARENT_SCOPE)
        return()
    endif()
    if(operation MATCHES "^(GET|JOIN|FIND)$")
        # vcpkg_list(<operation> <list-var> <out-var> <arg>)
        #            A0          A1         A2        A3
        if(NOT ARGC EQUAL "4")
            message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires three arguments.")
        endif()
        list("${operation}" list "${ARGV3}" out)
        set("${ARGV2}" "${out}" PARENT_SCOPE)
        return()
    endif()
    if(operation STREQUAL "SUBLIST")
        # vcpkg_list(SUBLIST <list-var> <begin> <length> <out-var>)
        #            A0      A1         A2      A3       A4
        if(NOT ARGC EQUAL "5")
            message(FATAL_ERROR "vcpkg_list sub-command SUBLIST requires four arguments.")
        endif()
        z_vcpkg_list_escape_once_more(list)
        list(SUBLIST list "${ARGV2}" "${ARGV3}" out)
        set("${ARGV4}" "${out}" PARENT_SCOPE)
        return()
    endif()

    # modification
    z_vcpkg_function_arguments(args 3)

    # APPEND and PREPEND don't need this fixup
    if(NOT operation MATCHES "^(APPEND|PREPEND)$")
        # all the other operations _do_ need it
        z_vcpkg_list_escape_once_more(list)
    endif()
    # inserters and remove_item require the arguments to be fixed up as well
    if(operation MATCHES "^(APPEND|PREPEND|INSERT|REMOVE_ITEM)$")
        z_vcpkg_list_escape_once_more(args)
    elseif(operation MATCHES "^(POP_BACK|POP_FRONT)$" AND NOT ARGC EQUAL 2)
        # getting a value from PUSH_BACK/POP_BACK is unsupported
        message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires one argument.")
    elseif(operation MATCHES "^(FILTER|TRANSFORM)$")
        # regexes are hard
        message(FATAL_ERROR "vcpkg_list sub-command ${operation} is currently unsupported.")
    endif()

    list("${operation}" list ${args})
    set("${list_var}" "${list}" PARENT_SCOPE)
endfunction()
