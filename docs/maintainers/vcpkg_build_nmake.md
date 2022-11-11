# vcpkg_build_nmake

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_build_nmake.md).

Build a msvc makefile project.

## Usage:
```cmake
vcpkg_build_nmake(
    SOURCE_PATH <${SOURCE_PATH}>
    [PROJECT_SUBPATH <${SUBPATH}>]
    [PROJECT_NAME <${MAKEFILE_NAME}>]
    [LOGFILE_ROOT <prefix>]
    [CL_LANGUAGE <language-name>]
    [PREFER_JOM]
    [PRERUN_SHELL <${SHELL_PATH}>]
    [PRERUN_SHELL_DEBUG <${SHELL_PATH}>]
    [PRERUN_SHELL_RELEASE <${SHELL_PATH}>]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
    [TARGET <all>...]
    [ENABLE_INSTALL]
)
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the source files.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PROJECT_SUBPATH
Specifies the sub directory containing the makefile.

### PROJECT_NAME
Specifies the name of the makefile.
Default is `makefile.vc`

### LOGFILE_ROOT
Specifies a log file prefix.

### CL_LANGUAGE
Specifies the language for setting up flags in the `_CL_` environment variable.
The default language is `CXX`.
To disable the modification of `_CL_`, use `NONE`.

### PREFER_JOM
Specifies that a parallel build with `jom` should be attempted.
This is useful for faster builds of makefiles which process many independent targets
and which cannot benefit from the `/MP` cl option.
To mitigate issues with concurrency-unaware makefiles, a normal `nmake` build is run after `jom` errors.

### PRERUN_SHELL
Script that needs to be called before build.

### PRERUN_SHELL_DEBUG
Script that needs to be called before debug build.

### PRERUN_SHELL_RELEASE
Script that needs to be called before release build.

### OPTIONS
Additional options passed to the build command.

### OPTIONS_RELEASE
Additional options passed to the build command for the release build. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to the build command for the debug build. These are in addition to `OPTIONS`.

### TARGET
The list of targets passed to the build command.
If not specified, target `all` will be passed.

### ENABLE_INSTALL
Adds `install` to the list of targets passed to the build command,
and passes the install prefix in the `INSTALLDIR` makefile variable.

## Notes:
You can use the alias [`vcpkg_install_nmake()`](vcpkg_install_nmake.md) function if your makefile supports the
"install" target.

## Examples

* [librttopo](https://github.com/microsoft/vcpkg/blob/master/ports/librttopo/portfile.cmake)
* [openssl](https://github.com/microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_build\_nmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_build_nmake.cmake)
