#[===[.md:
# z_vcpkg_prettify_command_line

**Only for internal use in vcpkg helpers. Behavior and arguments will change without notice.**
Turn a command line into a formatted string.

```cmake
z_vcpkg_prettify_command_line(<out-var> <argument>...)
```

This command is for internal use, when printing out to a message.

## Examples

* `scripts/cmake/vcpkg_execute_build_process.cmake`
* `scripts/cmake/vcpkg_execute_required_process.cmake`
* `scripts/cmake/vcpkg_execute_required_process_repeat.cmake`
#]===]

function(z_vcpkg_prettify_command_line OUT_VAR)
    set(OUTPUT "")
    z_vcpkg_function_arguments(ARGS 1)
    foreach(v IN LISTS ARGS)
        string(REPLACE [[\]] [[\\]] v "${v}")
        if(v MATCHES "( )")
            string(REPLACE [["]] [[\"]] v "${v}")
            list(APPEND OUTPUT "\"${v}\"")
        else()
            list(APPEND OUTPUT "${v}")
        endif()
    endforeach()
    list(JOIN "${OUT_VAR}" " " OUTPUT)
endfunction()
