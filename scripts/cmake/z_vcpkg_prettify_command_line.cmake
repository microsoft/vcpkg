#[===[.md:
# z_vcpkg_prettify_command_line

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
    z_vcpkg_cmake_function_arguments(ARGUMENTS 1)
    foreach(v IN LISTS ARGUMENTS)
        if(v MATCHES "( )")
            list(APPEND OUTPUT "\"${v}\"")
        else()
            list(APPEND OUTPUT "${v}")
        endif()
    endforeach()
    list(JOIN "${OUT_VAR}" " " OUTPUT)
endfunction()
