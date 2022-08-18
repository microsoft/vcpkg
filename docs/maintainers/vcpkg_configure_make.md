# vcpkg_configure_make

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_configure_make.md).

Configure configure for Debug and Release builds of a project.

## Usage
```cmake
vcpkg_configure_make(
    SOURCE_PATH <${SOURCE_PATH}>
    [AUTOCONFIG]
    [USE_WRAPPERS]
    [DETERMINE_BUILD_TRIPLET]
    [BUILD_TRIPLET "--host=x64 --build=i686-unknown-pc"]
    [NO_ADDITIONAL_PATHS]
    [CONFIG_DEPENDENT_ENVIRONMENT <SOME_VAR>...]
    [CONFIGURE_ENVIRONMENT_VARIABLES <SOME_ENVVAR>...]
    [ADD_BIN_TO_PATH]
    [DISABLE_VERBOSE_FLAGS]
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

### SKIP_CONFIGURE
Skip configure process

### USE_WRAPPERS
Use autotools ar-lib and compile wrappers (only applies to windows cl and lib)

### BUILD_TRIPLET
Used to pass custom --build/--target/--host to configure. Can be globally overwritten by VCPKG_MAKE_BUILD_TRIPLET

### DETERMINE_BUILD_TRIPLET
For ports having a configure script following the autotools rules for selecting the triplet

### NO_ADDITIONAL_PATHS
Don't pass any additional paths except for --prefix to the configure call

### AUTOCONFIG
Need to use autoconfig to generate configure file.

### PRERUN_SHELL
Script that needs to be called before configuration (do not use for batch files which simply call autoconf or configure)

### ADD_BIN_TO_PATH
Adds the appropriate Release and Debug `bin\` directories to the path during configure such that executables can run against the in-tree DLLs.

### DISABLE_VERBOSE_FLAGS
Do not pass '--disable-silent-rules --verbose' to configure.

### OPTIONS
Additional options passed to configure during the configuration.

### OPTIONS_RELEASE
Additional options passed to configure during the Release configuration. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to configure during the Debug configuration. These are in addition to `OPTIONS`.

### CONFIG_DEPENDENT_ENVIRONMENT
List of additional configuration dependent environment variables to set. 
Pass SOMEVAR to set the environment and have SOMEVAR_(DEBUG|RELEASE) set in the portfile to the appropriate values
General environment variables can be set from within the portfile itself. 

### CONFIGURE_ENVIRONMENT_VARIABLES
List of additional environment variables to pass via the configure call. 

## Notes
This command supplies many common arguments to configure. To see the full list, examine the source.

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_configure\_make.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_make.cmake)
