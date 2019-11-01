# vcpkg_configure_make

Configure `configure` for Debug and Release builds of a project.

## Usage
```cmake
vcpkg_configure_make(
    SOURCE_PATH <${SOURCE_PATH}>
    [AUTOCONFIG]
    [DISABLE_AUTO_HOST]
    [DISABLE_AUTO_DST]
    [GENERATOR]
    [NO_DEBUG]
    [SKIP_CONFIGURE]
    [PROJECT_SUBPATH <${PROJ_SUBPATH}>]
    [PRERUN_SHELL <${SHELL_PATH}>]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
)
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the `configure`/`configure.ac`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PROJECT_SUBPATH
Specifies the directory containing the ``configure`/`configure.ac`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
Should use `GENERATOR NMake` first.

### NO_DEBUG
This port doesn't support debug mode.

### SKIP_CONFIGURE
Skip configure process

### AUTOCONFIG
Need to use autoconfig to generate configure file.

### DISABLE_AUTO_HOST
Don't set host automatically, the default value is `i686`.
If use this option, you will need to set host manually.

### DISABLE_AUTO_DST
Don't set installation path automatically, the default value is `${CURRENT_PACKAGES_DIR}` and `${CURRENT_PACKAGES_DIR}/debug`
If use this option, you will need to set dst path manually.

### GENERATOR
Specifies the precise generator to use.
NMake: nmake(windows) make(unix)
MAKE: make(windows) make(unix)

### PRERUN_SHELL
Script that needs to be called before configuration

### OPTIONS
Additional options passed to configure during the configuration.

### OPTIONS_RELEASE
Additional options passed to configure during the Release configuration. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to configure during the Debug configuration. These are in addition to `OPTIONS`.

## Notes
This command supplies many common arguments to configure. To see the full list, examine the source.

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)

## Source
[scripts/cmake/vcpkg_configure_make.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_make.cmake)
