# z_vcpkg_forward_output_variable

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/).

This macro is a simple forward-er to PARENT_SCOPE.

```cmake
z_vcpkg_forward_output_variable(output_var var_to_forward)
```

is equivalent to

```cmake
if(DEFINED output_var)
    if(DEFINED value_var)
        set("${output_var}" "${value_var}" PARENT_SCOPE)
    else()
        unset("${output_var}" PARENT_SCOPE)
    endif()
endif()
```

## Source
[scripts/cmake/z\_vcpkg\_forward\_output\_variable.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/z_vcpkg_forward_output_variable.cmake)
