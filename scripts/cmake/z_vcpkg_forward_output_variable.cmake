#[===[.md:
# z_vcpkg_forward_output_variable

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
#]===]

macro(z_vcpkg_forward_output_variable output_var var_to_forward)
    if(DEFINED "${output_var}")
        if(DEFINED "${var_to_forward}")
            set("${${output_var}}" "${${var_to_forward}}" PARENT_SCOPE)
        else()
            unset("${${output_var}}" PARENT_SCOPE)
        endif()
    endif()
endmacro()