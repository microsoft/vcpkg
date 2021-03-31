#[===[.md:
# x_vcpkg_get_pkgconfig_libs

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
#]===]
function(x_vcpkg_get_pkgconfig_libs)
    cmake_parse_arguments(PARSE_ARGV 0 x_vcpkg_get_pkgconfig_libs "" "" "MODULES")
    if(NOT x_vcpkg_get_pkgconfig_libs_MODULES)
        message(FATAL_ERROR "x_vcpkg_get_pkgconfig_libs requires parameter PORTS!")
    endif()

    vcpkg_find_acquire_program(PKGCONFIG)
    set(backup_PKG_CONFIG_PATH "$ENV{PKG_CONFIG_PATH}")

    foreach(_module IN LISTS x_vcpkg_get_pkgconfig_libs_MODULES)
        if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/pkgconfig")
            set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/lib/pkgconfig${VCPKG_HOST_PATH_SEPARATOR}${backup_PKG_CONFIG_PATH}")
            execute_process(
                COMMAND "${PKGCONFIG}" --libs ${_module}
                OUTPUT_VARIABLE ${_module}_LIBS_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            execute_process(
                COMMAND "${PKGCONFIG}" --libs-only-l ${_module}
                OUTPUT_VARIABLE ${_module}_LIBRARIES_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            execute_process(
                COMMAND "${PKGCONFIG}" --cflags-only-I ${_module}
                OUTPUT_VARIABLE ${_module}_INCLUDE_DIRECTORIES
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
        endif()
        if(EXISTS "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig")
            set(ENV{PKG_CONFIG_PATH} "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig${VCPKG_HOST_PATH_SEPARATOR}${backup_PKG_CONFIG_PATH}")
            execute_process(
                COMMAND "${PKGCONFIG}" --libs ${_module}
                OUTPUT_VARIABLE ${_module}_LIBS_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            execute_process(
                COMMAND "${PKGCONFIG}" --libs-only-l ${_module}
                OUTPUT_VARIABLE ${_module}_LIBRARIES_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if(NOT ${_module}_INCLUDE_DIRECTORIES)
                execute_process(
                    COMMAND "${PKGCONFIG}" --cflags-only-I ${_module}
                    OUTPUT_VARIABLE ${_module}_INCLUDE_DIRECTORIES
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                )
            endif()
        endif()

        set(${_module}_LIBRARIES_RELEASE "${${_module}_LIBRARIES_RELEASE}" PARENT_SCOPE)
        set(${_module}_LIBRARIES_DEBUG "${${_module}_LIBRARIES_DEBUG}" PARENT_SCOPE)
        set(${_module}_LIBS_RELEASE "${${_module}_LIBRARIES_RELEASE}" PARENT_SCOPE)
        set(${_module}_LIBS_DEBUG "${${_module}_LIBRARIES_DEBUG}" PARENT_SCOPE)
        set(${_module}_INCLUDE_DIRECTORIES "${${_module}_INCLUDE_DIRECTORIES}" PARENT_SCOPE)
    endforeach()
    set(ENV{PKG_CONFIG_PATH} "${backup_PKG_CONFIG_PATH}")

endfunction()

