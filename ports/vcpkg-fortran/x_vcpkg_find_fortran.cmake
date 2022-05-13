#[===[.md:
# x_vcpkg_find_fortran

Checks if a Fortran compiler can be found.
Windows only: If not it will try to use one internal to vcpkg

## Usage
```cmake
x_vcpkg_find_fortran(OUT_OPTIONS <var>
                     OUT_OPTIONS_RELEASE <var_rel>
                     OUT_OPTIONS_DEBUG <var_dbg>
                    )
```

## Example
```cmake
x_vcpkg_find_fortran(OUT_OPTIONS fortran_args
                     OUT_OPTIONS_RELEASE fortran_args_rel
                     OUT_OPTIONS_DEBUG fortran_args_dbg
                    )
# ...
vcpkg_configure_cmake(...
    OPTIONS
        ${fortran_args}
    OPTIONS_RELEASE
        ${fortran_args_rel}
    OPTIONS_DEBUG
        ${fortran_args_dbg}
)
```
#]===]
function(x_vcpkg_find_fortran)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "OUT_OPTIONS;OUT_OPTIONS_RELEASE;OUT_OPTIONS_DEBUG" "")
    set(${arg_OUT_OPTIONS} "-DVCPKG_SETUP_CMAKE_PROGRAM_PATH:BOOL=OFF" PARENT_SCOPE) #  to avoid flang from llvm to be picked up
endfunction()
