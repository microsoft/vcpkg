#[===[.md:
# x_vcpkg_get_pkgconfig_modules

Experimental
Retrieve required module information from pkgconfig modules

## Usage
```cmake
x_vcpkg_get_pkgconfig_modules(
    PREFIX <prefix>
    MODULES <pkgconfig_modules>...
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
Returns `"${PKGCONFIG}"  --cflags-only-I` in <prefix>_INCLUDE_DIRS

## Examples

* [qt5-base](https://github.com/microsoft/vcpkg/blob/master/ports/qt5-base/portfile.cmake)
#]===]
function(x_vcpkg_get_pkgconfig_modules)
    cmake_parse_arguments(PARSE_ARGV 0 x_vcpkg_get_pkgconfig_modules "LIBS;LIBRARIES;LIBRARIES_DIR;INCLUDE_DIRS;" "PREFIX" "MODULES")
    if(NOT x_vcpkg_get_pkgconfig_modules_PREFIX)
        message(FATAL_ERROR "x_vcpkg_get_pkgconfig_modules requires parameter PREFIX!")
    endif()
    if(NOT x_vcpkg_get_pkgconfig_modules_MODULES)
        message(FATAL_ERROR "x_vcpkg_get_pkgconfig_modules requires parameter MODULES!")
    endif()

    set(_prefix "${x_vcpkg_get_pkgconfig_modules_PREFIX}")
    set(_modules "${x_vcpkg_get_pkgconfig_modules_MODULES}")

    vcpkg_find_acquire_program(PKGCONFIG)
    set(backup_PKG_CONFIG_PATH "$ENV{PKG_CONFIG_PATH}")

    set(var_suffixes)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_set_pkgconfig_path("${CURRENT_INSTALLED_DIR}/lib/pkgconfig" "${backup_PKG_CONFIG_PATH}")
        if(x_vcpkg_get_pkgconfig_modules_LIBS)
            execute_process(
                COMMAND "${PKGCONFIG}" --libs ${_modules}
                OUTPUT_VARIABLE ${_prefix}_LIBS_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            list(APPEND var_suffixes LIBS_RELEASE)
        endif()
        if(x_vcpkg_get_pkgconfig_modules_LIBRARIES)
            execute_process(
                COMMAND "${PKGCONFIG}" --libs-only-l ${_modules}
                OUTPUT_VARIABLE ${_prefix}_LIBRARIES_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            list(APPEND var_suffixes LIBRARIES_RELEASE)
        endif()
        if(x_vcpkg_get_pkgconfig_modules_LIBRARIES_DIRS)
            execute_process(
                COMMAND "${PKGCONFIG}" --libs-only-L ${_modules}
                OUTPUT_VARIABLE ${_prefix}_LIBRARIES_DIRS_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            list(APPEND var_suffixes LIBRARIES_DIRS_RELEASE)
        endif()
        if(x_vcpkg_get_pkgconfig_modules_INCLUDE_DIRS)
            execute_process(
                COMMAND "${PKGCONFIG}" --cflags-only-I ${_modules}
                OUTPUT_VARIABLE ${_prefix}_INCLUDE_DIRS
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            list(APPEND var_suffixes INCLUDE_DIRS)
        endif()
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_set_pkgconfig_path("${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig" "${backup_PKG_CONFIG_PATH}")
        if(x_vcpkg_get_pkgconfig_modules_LIBS)
            execute_process(
                COMMAND "${PKGCONFIG}" --libs ${_modules}
                OUTPUT_VARIABLE ${_prefix}_LIBS_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            list(APPEND var_suffixes LIBS_DEBUG)
        endif()
        if(x_vcpkg_get_pkgconfig_modules_LIBRARIES)
            execute_process(
                COMMAND "${PKGCONFIG}" --libs-only-l ${_modules}
                OUTPUT_VARIABLE ${_prefix}_LIBRARIES_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            list(APPEND var_suffixes LIBRARIES_DEBUG)
        endif()
        if(x_vcpkg_get_pkgconfig_modules_LIBRARIES_DIRS)
            execute_process(
                COMMAND "${PKGCONFIG}" --libs-only-L ${_modules}
                OUTPUT_VARIABLE ${_prefix}_LIBRARIES_DIRS_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            list(APPEND var_suffixes LIBRARIES_DIRS_DEBUG)
        endif()
        if(x_vcpkg_get_pkgconfig_modules_INCLUDE_DIRS AND NOT ${_prefix}_INCLUDE_DIRS)
            execute_process(
                COMMAND "${PKGCONFIG}" --cflags-only-I ${_modules}
                OUTPUT_VARIABLE ${_prefix}_INCLUDE_DIRS
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            list(APPEND var_suffixes INCLUDE_DIRS)
        endif()
    endif()
    set(ENV{PKG_CONFIG_PATH} "${backup_PKG_CONFIG_PATH}")

    foreach(_var IN LISTS var_suffixes)
        set(${_prefix}_${_var} "${${_prefix}_${_var}}" PARENT_SCOPE)
    endforeach()
endfunction()

function(z_vcpkg_set_pkgconfig_path _path _backup)
    if(${_backup})
        set(ENV{PKG_CONFIG_PATH} "${_path}${VCPKG_HOST_PATH_SEPARATOR}${_backup}")
    else()
        set(ENV{PKG_CONFIG_PATH} "${_path}")
    endif()
endfunction()
