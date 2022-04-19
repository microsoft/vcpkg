#[===[.md:
# vcpkg_install_nmake

Build and install a msvc makefile project.

## Usage:
```cmake
vcpkg_install_nmake(
    SOURCE_PATH <${SOURCE_PATH}>
    [NO_DEBUG]
    [TARGET <all>]
    PROJECT_SUBPATH <${SUBPATH}>
    PROJECT_NAME <${MAKEFILE_NAME}>
    [PRERUN_SHELL <${SHELL_PATH}>]
    [PRERUN_SHELL_DEBUG <${SHELL_PATH}>]
    [PRERUN_SHELL_RELEASE <${SHELL_PATH}>]
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

### PRERUN_SHELL
Script that needs to be called before build

### PRERUN_SHELL_DEBUG
Script that needs to be called before debug build

### PRERUN_SHELL_RELEASE
Script that needs to be called before release build

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

## Examples

* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
#]===]

function(vcpkg_install_nmake)
    vcpkg_list(SET multi_value_args
        TARGET
        OPTIONS OPTIONS_DEBUG OPTIONS_RELEASE
        PRERUN_SHELL PRERUN_SHELL_DEBUG PRERUN_SHELL_RELEASE)

    cmake_parse_arguments(PARSE_ARGV 0 arg
        "NO_DEBUG"
        "SOURCE_PATH;PROJECT_SUBPATH;PROJECT_NAME"
        "${multi_value_args}"
    )
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified")
    endif()
    
    if(NOT VCPKG_HOST_IS_WINDOWS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} only support windows.")
    endif()

    # backwards-compatibility hack
    # gdal passes `arg_OPTIONS_DEBUG` (and RELEASE) as a single argument,
    # so we need to split them again
    set(arg_OPTIONS_DEBUG ${arg_OPTIONS_DEBUG})
    set(arg_OPTIONS_RELEASE ${arg_OPTIONS_RELEASE})
    
    vcpkg_list(SET extra_args)
    # switch args
    if(arg_NO_DEBUG)
        vcpkg_list(APPEND extra_args NO_DEBUG)
    endif()

    # single args
    foreach(arg IN ITEMS PROJECT_SUBPATH PROJECT_NAME)
        if(DEFINED "arg_${arg}")
            vcpkg_list(APPEND extra_args ${arg} "${arg_${arg}}")
        endif()
    endforeach()

    # multi-value args
    foreach(arg IN LISTS multi_value_args)
        if(DEFINED "arg_${arg}")
            vcpkg_list(APPEND extra_args ${arg} ${arg_${arg}})
        endif()
    endforeach()

    vcpkg_build_nmake(
        SOURCE_PATH "${arg_SOURCE_PATH}"
        ENABLE_INSTALL
        LOGFILE_ROOT install
        ${extra_args})
endfunction()
