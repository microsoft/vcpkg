# vcpkg_find_fortran

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_find_fortran.md).

Checks if a Fortran compiler can be found.
Windows(x86/x64) Only: If not it will switch/enable MinGW gfortran 
                       and return required cmake args for building. 

## Usage
```cmake
vcpkg_find_fortran(<out_var>)
```

## Example
```cmake
vcpkg_find_fortran(fortran_args)
# ...
vcpkg_configure_cmake(...
    OPTIONS
        ${fortran_args}
)
```

## Source
[scripts/cmake/vcpkg\_find\_fortran.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_find_fortran.cmake)
