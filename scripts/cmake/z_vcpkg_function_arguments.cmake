#[===[.md:
# z_vcpkg_function_arguments

**Only for internal use in vcpkg helpers. Behavior and arguments will change without notice.**
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

# NOTE: this function definition is copied directly to scripts/buildsystems/vcpkg.cmake
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
    if(z_vcpkg_function_arguments_LAST_ARG GREATER_EQUAL z_vcpkg_function_arguments_FIRST_ARG)
        foreach(z_vcpkg_function_arguments_N RANGE "${z_vcpkg_function_arguments_FIRST_ARG}" "${z_vcpkg_function_arguments_LAST_ARG}")
            string(REPLACE ";" "\\;" z_vcpkg_function_arguments_ESCAPED_ARG "${ARGV${z_vcpkg_function_arguments_N}}")
            list(APPEND "${OUT_VAR}" "${z_vcpkg_function_arguments_ESCAPED_ARG}")
        endforeach()
    endif()
endmacro()
