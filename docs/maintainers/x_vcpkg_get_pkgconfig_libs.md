# x_vcpkg_get_pkgconfig_libs

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/x_vcpkg_get_pkgconfig_libs.md).

Experimental
Retrieve required libraries from pkgconfig modules

## Usage
```cmake
x_vcpkg_get_pkgconfig_libs(
    MODULES <name>...
)
```
## Parameters
### MODULES
List of pkgconfig modules to retrieve information about.
Information will be stored in 
<name>_LIBS_(_DEBUG|_RELEASE). ( contains the result of --libs)
<name>_LIBRARIES(_DEBUG|_RELEASE). (only contains the result of --libs-only-l)
<name>_INCLUDE_DIRECTORIES.        (only contains the result of --cflags-only-I)

## Examples

* [qt5-base](https://github.com/microsoft/vcpkg/blob/master/ports/qt5-base/portfile.cmake)

## Source
[scripts/cmake/x\_vcpkg\_get\_pkgconfig\_libs.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/x_vcpkg_get_pkgconfig_libs.cmake)
