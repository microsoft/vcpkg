# vcpkg_install_nmake

Build and install a msvc makefile project.

## Usage:
```cmake
vcpkg_install_nmake(
    SOURCE_PATH <${SOURCE_PATH}>
    [NO_DEBUG]
    PROJECT_SUBPATH <${SUBPATH}>
    PROJECT_NAME <${MAKEFILE_NAME}>
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the source files.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PROJECT_SUBPATH
Specifies the sub directory containing the `makefile.vc`/`makefile.mak`/`makefile.msvc` or other msvc makefile.

### PROJECT_NAME
Specifies the name of msvc makefile name.
Default is makefile.vc

### NO_DEBUG
This port doesn't support debug mode.

### OPTIONS
Additional options passed to generate during the generation.

### OPTIONS_RELEASE
Additional options passed to generate during the Release generation. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to generate during the Debug generation. These are in addition to `OPTIONS`.

## Parameters:
See [`vcpkg_build_nmake()`](vcpkg_build_nmake.md).

## Notes:
This command transparently forwards to [`vcpkg_build_nmake()`](vcpkg_build_nmake.md), adding `ENABLE_INSTALL`

## Source
[scripts/cmake/vcpkg_install_nmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_nmake.cmake)
