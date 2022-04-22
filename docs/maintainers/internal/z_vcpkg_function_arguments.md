# z_vcpkg_function_arguments

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/).

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

## Source
[scripts/cmake/z\_vcpkg\_function\_arguments.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/z_vcpkg_function_arguments.cmake)
