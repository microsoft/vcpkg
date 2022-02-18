# x_vcpkg_pkgconfig_get_modules

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-pkgconfig-get-modules/x_vcpkg_pkgconfig_get_modules.md).

Experimental
Retrieve required module information from pkgconfig modules

## Usage
```cmake
x_vcpkg_pkgconfig_get_modules(
    PREFIX <prefix>
    MODULES <pkgconfig_modules>...
    [CFLAGS]
    [LIBS]
    [LIBRARIES]
    [LIBRARIES_DIRS]
    [INCLUDE_DIRS]
)
```
## Parameters

### PREFIX
Used variable prefix to use

### MODULES
List of pkgconfig modules to retrieve information for.

### LIBS
Returns `"${PKGCONFIG}" --libs` in <prefix>_LIBS_(DEBUG|RELEASE)

### LIBRARIES
Returns `"${PKGCONFIG}" --libs-only-l` in <prefix>_LIBRARIES_(DEBUG|RELEASE)

### LIBRARIES_DIRS
Returns `"${PKGCONFIG}" --libs-only-L` in <prefix>_LIBRARIES_DIRS_(DEBUG|RELEASE)

### INCLUDE_DIRS
Returns `"${PKGCONFIG}"  --cflags-only-I` in <prefix>_INCLUDE_DIRS_(DEBUG|RELEASE)

## Examples

* [qt5-base](https://github.com/microsoft/vcpkg/blob/master/ports/qt5-base/portfile.cmake)

## Source
[ports/vcpkg-pkgconfig-get-modules/x\_vcpkg\_pkgconfig\_get\_modules.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-pkgconfig-get-modules/x_vcpkg_pkgconfig_get_modules.cmake)
