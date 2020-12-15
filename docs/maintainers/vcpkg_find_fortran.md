# vcpkg_find_fortran

Checks if a Fortran compiler can be found.
Windows(x86/x64) Only: If not it will switch/enable MinGW gfortran 
                       and return required cmake args for building. 

## Usage
```cmake
vcpkg_find_fortran(<additional_cmake_args_out>)
```

## Source
[scripts/cmake/vcpkg_find_fortran.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_find_fortran.cmake)
