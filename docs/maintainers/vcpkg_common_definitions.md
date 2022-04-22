# vcpkg_common_definitions

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_common_definitions.md).

This file defines the following variables which are commonly needed or used in portfiles:

```cmake
VCPKG_TARGET_IS_<target>                 with <target> being one of the following: WINDOWS, UWP, MINGW, LINUX, OSX, ANDROID, FREEBSD, OPENBSD. only defined if <target>
VCPKG_HOST_IS_<host>                     with <host> being one of the following: WINDOWS, LINUX, OSX, FREEBSD, OPENBSD. only defined if <host>
VCPKG_HOST_PATH_SEPARATOR                Host specific path separator (USAGE: "<something>${VCPKG_HOST_PATH_SEPARATOR}<something>"; only use and pass variables with VCPKG_HOST_PATH_SEPARATOR within "")
VCPKG_HOST_EXECUTABLE_SUFFIX             executable suffix of the host
VCPKG_TARGET_EXECUTABLE_SUFFIX           executable suffix of the target
VCPKG_HOST_BUNDLE_SUFFIX                 bundle suffix of the host
VCPKG_TARGET_BUNDLE_SUFFIX               bundle suffix of the target
VCPKG_TARGET_STATIC_LIBRARY_PREFIX       static library prefix for target (same as CMAKE_STATIC_LIBRARY_PREFIX)
VCPKG_TARGET_STATIC_LIBRARY_SUFFIX       static library suffix for target (same as CMAKE_STATIC_LIBRARY_SUFFIX)
VCPKG_TARGET_SHARED_LIBRARY_PREFIX       shared library prefix for target (same as CMAKE_SHARED_LIBRARY_PREFIX)
VCPKG_TARGET_SHARED_LIBRARY_SUFFIX       shared library suffix for target (same as CMAKE_SHARED_LIBRARY_SUFFIX)
VCPKG_TARGET_IMPORT_LIBRARY_PREFIX       import library prefix for target (same as CMAKE_IMPORT_LIBRARY_PREFIX)
VCPKG_TARGET_IMPORT_LIBRARY_SUFFIX       import library suffix for target (same as CMAKE_IMPORT_LIBRARY_SUFFIX)
VCPKG_FIND_LIBRARY_PREFIXES              target dependent prefixes used for find_library calls in portfiles
VCPKG_FIND_LIBRARY_SUFFIXES              target dependent suffixes used for find_library calls in portfiles
VCPKG_SYSTEM_LIBRARIES                   list of libraries are provide by the toolchain and are not managed by vcpkg
TARGET_TRIPLET                           the name of the current triplet to build for
CURRENT_INSTALLED_DIR                    the absolute path to the installed files for the current triplet
HOST_TRIPLET                             the name of the triplet corresponding to the host
CURRENT_HOST_INSTALLED_DIR               the absolute path to the installed files for the host triplet
VCPKG_CROSSCOMPILING                     Whether vcpkg is cross-compiling: in other words, whether TARGET_TRIPLET and HOST_TRIPLET are different
```

CMAKE_STATIC_LIBRARY_(PREFIX|SUFFIX), CMAKE_SHARED_LIBRARY_(PREFIX|SUFFIX) and CMAKE_IMPORT_LIBRARY_(PREFIX|SUFFIX) are defined for the target
Furthermore the variables CMAKE_FIND_LIBRARY_(PREFIXES|SUFFIXES) are also defined for the target so that
portfiles are able to use find_library calls to discover dependent libraries within the current triplet for ports.

## Source
[scripts/cmake/vcpkg\_common\_definitions.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_common_definitions.cmake)
