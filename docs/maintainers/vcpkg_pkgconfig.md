# vcpkg_pkgconfig

Uses pkg-config executable in order to retrieve usefull linkage info.
This is may be usefull in order to build tools for static build versions

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
