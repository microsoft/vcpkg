# vcpkg_common_definitions

File contains helpful variabls for portfiles which are commonly needed or used.

## The following variables are available:
```cmake
VCPKG_TARGET_IS_<target>                 with <target> being one of the following: WINDOWS, UWP, LINUX, OSX, ANDROID, FREEBSD. only defined if <target>
VCPKG_HOST_PATH_SEPARATOR                Host specific path separator (USAGE: "<something>${VCPKG_HOST_PATH_SEPARATOR}<something>"; only use and pass variables with VCPKG_HOST_PATH_SEPARATOR within "")
VCPKG_HOST_EXECUTABLE_SUFFIX             executable suffix of the host
VCPKG_TARGET_EXECUTABLE_SUFFIX           executable suffix of the target
VCPKG_TARGET_STATIC_LIBRARY_PREFIX       static library prefix for target (same as CMAKE_STATIC_LIBRARY_PREFIX)
VCPKG_TARGET_STATIC_LIBRARY_SUFFIX       static library suffix for target (same as CMAKE_STATIC_LIBRARY_SUFFIX)
VCPKG_TARGET_SHARED_LIBRARY_PREFIX       shared library prefix for target (same as CMAKE_SHARED_LIBRARY_PREFIX)
VCPKG_TARGET_SHARED_LIBRARY_SUFFIX       shared library suffix for target (same as CMAKE_SHARED_LIBRARY_SUFFIX)
VCPKG_TARGET_IMPORT_LIBRARY_PREFIX       import library prefix for target (same as CMAKE_IMPORT_LIBRARY_PREFIX)
VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX       import library suffix for target (same as CMAKE_IMPORT_LIBRARY_SUFFIX)
VCPKG_FIND_LIBRARY_PREFIXES              target dependent prefixes used for find_library calls in portfiles
VCPKG_FIND_LIBRARY_SUFFIXES              target dependent suffixes used for find_library calls in portfiles
```

CMAKE_STATIC_LIBRARY_(PREFIX|SUFFIX), CMAKE_SHARED_LIBRARY_(PREFIX|SUFFIX) and CMAKE_IMPORT_LIBRARY_(PREFIX|SUFFIX) are defined for the target
Furthermore the variables CMAKE_FIND_LIBRARY_(PREFIXES|SUFFIXES) are also defined for the target so that
portfiles are able to use find_library calls to discover dependent libraries within the current triplet for ports.


## Source
[scripts/cmake/vcpkg_common_definitions.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_common_definitions.cmake)
