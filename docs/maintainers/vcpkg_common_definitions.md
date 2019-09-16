# vcpkg_common_definitions

File contains helpful variabls for portfiles which are commonly needed or used.

## The following variables are available:
```cmake
VCPKG_TARGET_IS_<target>                 with <target> being one of the following: WINDOWS, UWP, LINUX, OSX, ANDROID, FREEBSD. only defined if <target>
VCPKG_TARGET_STATIC_LIBRARY_PREFIX       static library prefix for target (same as CMAKE_STATIC_LIBRARY_PREFIX)
VCPKG_TARGET_STATIC_LIBRARY_SUFFIX       static library suffix for target (same as CMAKE_STATIC_LIBRARY_SUFFIX)
VCPKG_TARGET_SHARED_LIBRARY_PREFIX       shared library prefix for target (same as CMAKE_SHARED_LIBRARY_PREFIX)
VCPKG_TARGET_SHARED_LIBRARY_SUFFIX       shared library suffix for target (same as CMAKE_SHARED_LIBRARY_SUFFIX)
```

CMAKE_STATIC_LIBRARY_PREFIX, CMAKE_STATIC_LIBRARY_SUFFIX, CMAKE_SHARED_LIBRARY_PREFIX, CMAKE_SHARED_LIBRARY_SUFFIX are defined for the target so that 
portfiles are able to use find_library calls to discover dependent libraries within the current triplet for ports. 


## Source
[scripts/cmake/vcpkg_common_definitions.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_common_definitions.cmake)
