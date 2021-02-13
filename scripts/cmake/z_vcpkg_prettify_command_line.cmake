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

function(z_vcpkg_prettify_command_line out_var)
    set(output_list "")
    z_vcpkg_function_arguments(args 1)
    foreach(v IN LISTS args)
        string(REPLACE [[\]] [[\\]] v "${v}")
        if(v MATCHES "( )")
            string(REPLACE [["]] [[\"]] v "${v}")
            list(APPEND output_list "\"${v}\"")
        else()
            list(APPEND output_list "${v}")
        endif()
    endforeach()
    list(JOIN output_list " " output)
    set("${out_var}" "${output}" PARENT_SCOPE)
endfunction()
