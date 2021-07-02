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

- `GET`, `REMOVE_ITEM`, and `REMOVE_AT` support only one index/value
- `POP_BACK` and `POP_FRONT` do not support getting the value into
  another out variable. Use C++ style `GET` then `POP_(BACK|FRONT)`.
- `FILTER` and `TRANSFORM` are unsupported.

See the [CMake documentation for `list()`](https://cmake.org/cmake/help/latest/command/list.html)
for more information.

## Notes: Some Weirdnesses

The most major weirdness is due to `""` pulling double-duty as "list of zero elements",
and "list of one element, which is empty". `vcpkg_list` always uses the former understanding.
This can cause weird behavior, for example:

```cmake
set(lst "")
vcpkg_list(APPEND lst "" "")
# lst = ";"
```

This is because you're appending two elements to the empty list.
One very weird behavior that comes out of this would be:

```cmake
set(lst "")
vcpkg_list(APPEND lst "")
# lst = ""
```

since `""` is the empty list, we append the empty element and end up with a list
of one element, which is empty. This does not happen for non-empty lists;
for example:

```cmake
set(lst "a")
vcpkg_list(APPEND lst "")
# lst = "a;"
```

only the empty list has this odd behavior.

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
        # vcpkg_list(<operation> <list-var> <arg> <out-var>)
        #            A0          A1         A2    A3
        if(NOT ARGC EQUAL "4")
            message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires three arguments.")
        endif()
        if(operation STREQUAL "GET")
            list(LENGTH list length)
            if(length EQUAL "0")
                message(FATAL_ERROR "vcpkg_list GET given empty list")
            elseif(ARGV2 GREATER_EQUAL length OR ARGV2 LESS "-${length}")
                message(FATAL_ERROR "vcpkg_list index: ${ARGV2} is not in range")
            endif()
        endif()
        list("${operation}" list "${ARGV2}" out)
        set("${ARGV3}" "${out}" PARENT_SCOPE)
        return()
    endif()
    if(operation STREQUAL "SUBLIST")
        # vcpkg_list(SUBLIST <list-var> <begin> <length> <out-var>)
        #            A0      A1         A2      A3       A4
        if(NOT ARGC EQUAL "5")
            message(FATAL_ERROR "vcpkg_list sub-command SUBLIST requires four arguments.")
        endif()
        list(LENGTH list length)
        if(ARGV2 LESS "0" OR (ARGV2 GREATER_EQUAL length AND NOT ARGV2 EQUAL "0"))
            message(FATAL_ERROR "vcpkg_list begin index: ${ARGV2} is out of range")
        endif()
        z_vcpkg_list_escape_once_more(list)
        list(SUBLIST list "${ARGV2}" "${ARGV3}" out)
        set("${ARGV4}" "${out}" PARENT_SCOPE)
        return()
    endif()

    # modification functions

    if(operation MATCHES "^(APPEND|PREPEND)$")
        # vcpkg_list(<operation> <list> [<element>...])
        #            A0          A1      A2...

        # if ARGC <= 2, then we don't have to do anything
        if(ARGC GREATER 2)
            z_vcpkg_function_arguments(args 2)
            if(list STREQUAL "")
                set("${list_var}" "${args}" PARENT_SCOPE)
            elseif(operation STREQUAL "APPEND")
                set("${list_var}" "${list};${args}" PARENT_SCOPE)
            else()
                set("${list_var}" "${args};${list}" PARENT_SCOPE)
            endif()
        endif()
        return()
    endif()
    if(operation STREQUAL "INSERT")
        # vcpkg_list(INSERT <list> <index> [<element>...])
        #            A0     A1     A2       A3...

        list(LENGTH list length)
        if(ARGV2 LESS "-{$length}" OR ARGV2 GREATER length)
            message(FATAL_ERROR "vcpkg_list index: ${ARGV2} out of range")
        endif()
        if(ARGC GREATER 3)
            # list(LENGTH) is one of the few subcommands that's fine
            list(LENGTH list length)
            if(ARGV2 LESS "0")
                math(EXPR ARGV2 "${length} + ${ARGV2}")
            endif()
            if(ARGV2 LESS "0" OR ARGV2 GREATER length)
                message(FATAL_ERROR "list index: ${ARGV2} out of range (-${length}, ${length})")
            endif()

            z_vcpkg_function_arguments(args 3)
            if(list STREQUAL "")
                set("${list_var}" "${args}" PARENT_SCOPE)
            elseif(ARGV2 EQUAL "0")
                set("${list_var}" "${args};${list}" PARENT_SCOPE)
            elseif(ARGV2 EQUAL length)
                set("${list_var}" "${list};${args}" PARENT_SCOPE)
            else()
                vcpkg_list(SUBLIST list 0 "${ARGV2}" list_start)
                vcpkg_list(SUBLIST list "${ARGV2}" -1 list_end)
                set("${list_var}" "${list_start};${args};${list_end}" PARENT_SCOPE)
            endif()
        elseif(ARGC LESS 3)
            message(FATAL_ERROR "vcpkg_list sub-command INSERT requires at least two arguments.")
        endif()
        return()
    endif()

    if(operation MATCHES "^(POP_BACK|POP_FRONT|REVERSE|REMOVE_DUPLICATES)$")
        # vcpkg_list(<operation> <list>)
        #            A0          A1
        if(NOT ARGC EQUAL 2)
            message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires one argument.")
        endif()
        z_vcpkg_list_escape_once_more(list)
        list("${operation}" list)
        set("${list_var}" "${list}" PARENT_SCOPE)
        return()
    endif()

    if(operation MATCHES "^(REMOVE_AT|REMOVE_ITEM)$")
        # vcpkg_list(<operation> <list> <index-or-item>)
        #            A0          A1     A2
        if(NOT ARGC EQUAL 3)
            message(FATAL_ERROR "vcpkg_list sub-command ${operation} requires two arguments.")
        endif()
        if(operation STREQUAL "REMOVE_AT")
            list(LENGTH list length)
            if(ARGV2 GREATER_EQUAL length OR ARGV2 LESS "-${length}")
                message(FATAL_ERROR "vcpkg_list index: ${ARGV2} out of range")
            endif()
        endif()

        z_vcpkg_list_escape_once_more(list)
        string(REPLACE [[;]] [[\;]] ARGV2 "${ARGV2}")

        list("${operation}" list "${ARGV2}")
        set("${list_var}" "${list}" PARENT_SCOPE)
        return()
    endif()

    message(FATAL_ERROR "vcpkg_list sub-command ${operation} is not yet implemented.")
endfunction()
