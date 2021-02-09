#[===[.md:
# z_vcpkg_add_fatal_error
Add a fatal error.

```cmake
z_vcpkg_add_fatal_error(<message>...)
```

We use this system, instead of `message(FATAL_ERROR)`,
since cmake prints a lot of nonsense if the toolchain errors out before it's found the build tools.

This `Z_VCPKG_HAS_FATAL_ERROR` must be checked before any filesystem operations are done,
since otherwise you might be doing something with bad variables set up.
#]===]
set(Z_VCPKG_FATAL_ERROR)
set(Z_VCPKG_HAS_FATAL_ERROR OFF)
function(z_vcpkg_add_fatal_error ERROR)
    if(NOT Z_VCPKG_HAS_FATAL_ERROR)
        set(Z_VCPKG_HAS_FATAL_ERROR ON PARENT_SCOPE)
        set(Z_VCPKG_FATAL_ERROR "${ERROR}" PARENT_SCOPE)
    else()
        string(APPEND Z_VCPKG_FATAL_ERROR "\n${ERROR}")
    endif()
endfunction()

#[===[.md:
# z_vcpkg_function_arguments

Get a list of the arguments which were passed in.
Unlike `ARGV`, which is simply the arguments joined with `;`,
so that `(A B)` is not distinguishable from `("A;B")`,
this macro gives `"A;B"` for the first argument list,
and `"A\;B"` for the second.

```cmake
z_vcpkg_function_arguments(<out-var> [<N>])
```

`z_vcpkg_function_arguments` gets the arguments between `ARGV<N>` and the last argument.
`<N>` defaults to `0`, so that all arguments are taken.

## Example:
```cmake
function(foo_replacement)
    z_vcpkg_function_arguments(ARGS)
    foo(${ARGS})
    ...
endfunction()
```
#]===]

# NOTE: this function definition is copied directly from scripts/cmake/z_vcpkg_function_arguments.cmake
# do not make changes here without making the same change there.
macro(z_vcpkg_function_arguments OUT_VAR)
    if("${ARGC}" EQUAL 1)
        set(z_vcpkg_function_arguments_FIRST_ARG 0)
    elseif("${ARGC}" EQUAL 2)
        set(z_vcpkg_function_arguments_FIRST_ARG "${ARGV1}")
    else()
        # vcpkg bug
        message(FATAL_ERROR "z_vcpkg_function_arguments: invalid arguments (${ARGV})")
    endif()

    set("${OUT_VAR}")

    # this allows us to get the value of the enclosing function's ARGC
    set(z_vcpkg_function_arguments_ARGC_NAME "ARGC")
    set(z_vcpkg_function_arguments_ARGC "${${z_vcpkg_function_arguments_ARGC_NAME}}")

    math(EXPR z_vcpkg_function_arguments_LAST_ARG "${z_vcpkg_function_arguments_ARGC} - 1")
    foreach(z_vcpkg_function_arguments_N RANGE "${z_vcpkg_function_arguments_FIRST_ARG}" "${z_vcpkg_function_arguments_LAST_ARG}")
        string(REPLACE ";" "\\;" z_vcpkg_function_arguments_ESCAPED_ARG "${ARGV${z_vcpkg_function_arguments_N}}")
        list(APPEND "${OUT_VAR}" "${z_vcpkg_function_arguments_ESCAPED_ARG}")
    endforeach()
endmacro()

#[===[.md:
# z_vcpkg_*_parent_scope_export
If you need to re-export variables to a parent scope from a call,
you can put these around the call to re-export those variables that have changed locally
to parent scope.

## Usage:
```cmake
z_vcpkg_start_parent_scope_export(
    [PREFIX <PREFIX>]
)
z_vcpkg_complete_parent_scope_export(
    [PREFIX <PREFIX>]
    [IGNORE_REGEX <REGEX>]
)
```

## Parameters
### PREFIX
The prefix to use to store the old variable values; defaults to `Z_VCPKG_PARENT_SCOPE_EXPORT`.
The value of each variable `<VAR>` will be stored in `${PREFIX}_<VAR>` by `start`,
and then every variable which is different from `${PREFIX}_VAR` will be re-exported by `complete`.

### IGNORE_REGEX
Variables with names matching this regex will not be exported even if their value has changed.

## Example:
```cmake
z_vcpkg_start_parent_scope_export()
_find_package(blah)
z_vcpkg_complete_parent_scope_export()
```
#]===]
# Notes: these do not use `cmake_parse_arguments` in order to support older versions of cmake,
# pre-3.7 and PARSE_ARGV
macro(z_vcpkg_start_parent_scope_export)
    if("${ARGC}" EQUAL "0")
        set(z_vcpkg_parent_scope_export_PREFIX "Z_VCPKG_PARENT_SCOPE_EXPORT")
    elseif("${ARGC}" EQUAL "2" AND "${ARGV0}" STREQUAL "PREFIX")
        set(z_vcpkg_parent_scope_export_PREFIX "${ARGV1}")
    else()
        message(FATAL_ERROR "Invalid parameters to z_vcpkg_start_parent_scope_export: (${ARGV})")
    endif()
    get_property(z_vcpkg_parent_scope_export_VARIABLE_LIST
        DIRECTORY PROPERTY "VARIABLES")
    foreach(z_vcpkg_parent_scope_export_VARIABLE IN LISTS z_vcpkg_parent_scope_export_VARIABLE_LIST)
        set("${z_vcpkg_parent_scope_export_PREFIX}_${z_vcpkg_parent_scope_export_VARIABLE}" "${${z_vcpkg_parent_scope_export_VARIABLE}}")
    endforeach()
endmacro()

macro(z_vcpkg_complete_parent_scope_export)
    set(z_vcpkg_parent_scope_export_PREFIX_FILLED OFF)
    if("${ARGC}" EQUAL "0")
        # do nothing, replace with default values
    elseif("${ARGC}" EQUAL "2")
        if("${ARGV0}" STREQUAL "PREFIX")
            set(z_vcpkg_parent_scope_export_PREFIX_FILLED ON)
            set(z_vcpkg_parent_scope_export_PREFIX "${ARGV1}")
        elseif("${ARGV0}" STREQUAL "IGNORE_REGEX")
            set(z_vcpkg_parent_scope_export_IGNORE_REGEX "${ARGV1}")
        else()
            message(FATAL_ERROR "Invalid arguments to z_vcpkg_complete_parent_scope_export: (${ARGV})")
        endif()
    elseif("${ARGC}" EQUAL "4")
        if("${ARGV0}" STREQUAL "PREFIX" AND "${ARGV2}" STREQUAL "IGNORE_REGEX")
            set(z_vcpkg_parent_scope_export_PREFIX_FILLED ON)
            set(z_vcpkg_parent_scope_export_PREFIX "${ARGV1}")
            set(z_vcpkg_parent_scope_export_IGNORE_REGEX "${ARGV3}")
        elseif("${ARGV0}" STREQUAL "IGNORE_REGEX" AND "${ARGV2}" STREQUAL "PREFIX")
            set(z_vcpkg_parent_scope_export_IGNORE_REGEX "${ARGV1}")
            set(z_vcpkg_parent_scope_export_PREFIX_FILLED ON)
            set(z_vcpkg_parent_scope_export_PREFIX "${ARGV3}")
        else()
            message(FATAL_ERROR "Invalid arguments to z_vcpkg_start_parent_scope_export: (${ARGV})")
        endif()
    else()
        message(FATAL_ERROR "Invalid arguments to z_vcpkg_complete_parent_scope_export: (${ARGV})")
    endif()

    if(NOT z_vcpkg_parent_scope_export_PREFIX)
        set(z_vcpkg_parent_scope_export_PREFIX "Z_VCPKG_PARENT_SCOPE_EXPORT")
    endif()

    get_property(z_vcpkg_parent_scope_export_VARIABLE_LIST
        DIRECTORY PROPERTY "VARIABLES")
    foreach(z_vcpkg_parent_scope_export_VARIABLE IN LISTS z_vcpkg_parent_scope_export_VARIABLE_LIST)
        if("${z_vcpkg_parent_scope_export_VARIABLE}" MATCHES "^${z_vcpkg_parent_scope_export_PREFIX}_")
            # skip the backup variables
            continue()
        endif()
        if("${z_vcpkg_parent_scope_export_VARIABLE}" MATCHES "^${z_vcpkg_parent_scope_export_PREFIX}_")
            # skip the backup variables
            continue()
        endif()

        if(DEFINED "${z_vcpkg_parent_scope_export_IGNORE_REGEX}" AND "${z_vcpkg_parent_scope_export_VARIABLE}" MATCHES "${z_vcpkg_parent_scope_export_IGNORE_REGEX}")
            # skip those variables which should be ignored
            continue()
        endif()

        if(NOT "${${z_vcpkg_parent_scope_export_PREFIX}_${z_vcpkg_parent_scope_export_VARIABLE}}" STREQUAL "${${z_vcpkg_parent_scope_export_VARIABLE}}")
            set("${z_vcpkg_parent_scope_export_VARIABLE}" "${${z_vcpkg_parent_scope_export_VARIABLE}}" PARENT_SCOPE)
        endif()
    endforeach()
endmacro()

#[===[.md:
# z_vcpkg_set_powershell_path

Gets either the path to powershell or powershell core,
and places it in the variable Z_VCPKG_POWERSHELL_PATH.
#]===]
function(z_vcpkg_set_powershell_path)
    # Attempt to use pwsh if it is present; otherwise use powershell
    if (NOT DEFINED Z_VCPKG_POWERSHELL_PATH)
        find_program(Z_VCPKG_PWSH_PATH pwsh)
        if (Z_VCPKG_PWSH_PATH)
            set(Z_VCPKG_POWERSHELL_PATH "${Z_VCPKG_PWSH_PATH}" CACHE INTERNAL "The path to the PowerShell implementation to use.")
        else()
            message(DEBUG "vcpkg: Could not find PowerShell Core; falling back to PowerShell")
            find_program(Z_VCPKG_BUILTIN_POWERSHELL_PATH powershell REQUIRED)
            if (Z_VCPKG_BUILTIN_POWERSHELL_PATH)
                set(Z_VCPKG_POWERSHELL_PATH "${Z_VCPKG_BUILTIN_POWERSHELL_PATH}" CACHE INTERNAL "The path to the PowerShell implementation to use.")
            else()
                message(WARNING "vcpkg: Could not find PowerShell; using static string 'powershell.exe'")
                set(Z_VCPKG_POWERSHELL_PATH "powershell.exe" CACHE INTERNAL "The path to the PowerShell implementation to use.")
            endif()
        endif()
    endif() # Z_VCPKG_POWERSHELL_PATH
endfunction()
