# vcpkg_pkgconfig

Uses pkg-config executable in order to retrieve usefull linkage info.
One use case is to retrieve link libraries in order to build tools for static build (that fails for some ports).

Some ${INSTALLED_DIR}/lib/pkgconfig/${package}.pc files should be fixed (especially some debug versions are not referencing proper files) for proper use. One example of package demonstrating how to fix the .pc file is zlib

## Usage
```cmake
vcpkg_pkgconfig(SYSTEM_LIBS_REL <slr> PACKAGE_LIBS_REL <plr> SYSTEM_LIBS_DBG <sld> PACKAGE_LIBS_DBG <pld>
    PACKAGES <packages>...
)
```

## Options
### APPEND
libraries are added to the provided "output variables" otherwise (default) those variables are erased first

### AS_STRING
libraries are provided as a space separated string otherwise (default) they are provided as a list (semicolon separated)

## Parameters
### SYSTEM_LIBS_REL
An out-list-variable which will be appended with the release build system libs needed for linking when using a given package.

### SYSTEM_LIBS_DBG
An out-list-variable which will be appended with the debug build package libs needed for linking when using a given package.

### PACKAGE_LIBS_REL
An out-list-variable which will be appended with the release build system libs needed for linking when using a given package.

### PACKAGE_LIBS_DBG
An out-list-variable which will be appended with the debug build package libs needed for linking when using a given package.

### PACKAGES
A list of packages to search for dependencies

## Examples

# Source
[scripts/cmake/vcpkg_pkgconfig.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_pkgconfig.cmake)
