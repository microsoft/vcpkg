# Mark variables as used so cmake doesn't complain about them
mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

# NOTE: to figure out what cmake versions are required for different things,
# grep for `CMake 3`. All version requirement comments should follow that format.

#[===[.md:
# z_vcpkg_add_fatal_error
Add a fatal error.

```cmake
z_vcpkg_add_fatal_error(<message>...)
```

We use this system, instead of `message(FATAL_ERROR)`,
since cmake prints a lot of nonsense if the toolchain errors out before it's found the build tools.

This `Z_VCPKG_HAS_FATAL_ERROR` must be checked before any filesystem operations are done,
since otherwise you might be doing something with bad variables set up.
#]===]
# this is defined above everything else so that it can be used.
set(Z_VCPKG_FATAL_ERROR)
set(Z_VCPKG_HAS_FATAL_ERROR OFF)
function(z_vcpkg_add_fatal_error ERROR)
    if(NOT Z_VCPKG_HAS_FATAL_ERROR)
        set(Z_VCPKG_HAS_FATAL_ERROR ON PARENT_SCOPE)
        set(Z_VCPKG_FATAL_ERROR "${ERROR}" PARENT_SCOPE)
    else()
        string(APPEND Z_VCPKG_FATAL_ERROR "\n${ERROR}")
    endif()
endfunction()

set(Z_VCPKG_CMAKE_REQUIRED_MINIMUM_VERSION "3.1")
if(CMAKE_VERSION VERSION_LESS Z_VCPKG_CMAKE_REQUIRED_MINIMUM_VERSION)
    message(FATAL_ERROR "vcpkg.cmake requires at least CMake ${Z_VCPKG_CMAKE_REQUIRED_MINIMUM_VERSION}.")
endif()
# this policy is required for this file; thus, CMake 3.1 is required.
cmake_policy(PUSH)
cmake_policy(SET CMP0054 NEW)

include(CMakeDependentOption)

# VCPKG toolchain options.
option(VCPKG_VERBOSE "Enables messages from the VCPKG toolchain for debugging purposes." OFF)
mark_as_advanced(VCPKG_VERBOSE)

option(VCPKG_APPLOCAL_DEPS "Automatically copy dependencies into the output directory for executables." ON)
option(X_VCPKG_APPLOCAL_DEPS_SERIALIZED "(experimental) Add USES_TERMINAL to VCPKG_APPLOCAL_DEPS to force serialization." OFF)
option(X_VCPKG_APPLOCAL_DEPS_INSTALL "(experimental) Automatically copy dependencies into the install target directory for executables." OFF)

# Manifest options and settings
if(NOT DEFINED VCPKG_MANIFEST_DIR)
    if(EXISTS "${CMAKE_SOURCE_DIR}/vcpkg.json")
        set(VCPKG_MANIFEST_DIR "${CMAKE_SOURCE_DIR}")
    endif()
endif()
set(VCPKG_MANIFEST_DIR "${VCPKG_MANIFEST_DIR}"
    CACHE PATH "The path to the vcpkg manifest directory." FORCE)

if(DEFINED VCPKG_MANIFEST_DIR AND NOT VCPKG_MANIFEST_DIR STREQUAL "")
    set(Z_VCPKG_HAS_MANIFEST_DIR ON)
else()
    set(Z_VCPKG_HAS_MANIFEST_DIR OFF)
endif()

option(VCPKG_MANIFEST_MODE "Use manifest mode, as opposed to classic mode." "${Z_VCPKG_HAS_MANIFEST_DIR}")

if(VCPKG_MANIFEST_MODE AND NOT Z_VCPKG_HAS_MANIFEST_DIR)
    z_vcpkg_add_fatal_error(
"vcpkg manifest mode was enabled, but we couldn't find a manifest file (vcpkg.json)
in the current source directory (${CMAKE_CURRENT_SOURCE_DIR}).
Please add a manifest, or disable manifests by turning off VCPKG_MANIFEST_MODE."
    )
endif()

if(NOT DEFINED CACHE{Z_VCPKG_CHECK_MANIFEST_MODE})
    set(Z_VCPKG_CHECK_MANIFEST_MODE "${VCPKG_MANIFEST_MODE}"
        CACHE INTERNAL "Making sure VCPKG_MANIFEST_MODE doesn't change")
endif()

if(NOT VCPKG_MANIFEST_MODE AND Z_VCPKG_CHECK_MANIFEST_MODE)
    z_vcpkg_add_fatal_error([[
vcpkg manifest mode was disabled for a build directory where it was initially enabled.
This is not supported. Please delete the build directory and reconfigure.
]])
elseif(VCPKG_MANIFEST_MODE AND NOT Z_VCPKG_CHECK_MANIFEST_MODE)
    z_vcpkg_add_fatal_error([[
vcpkg manifest mode was enabled for a build directory where it was initially disabled.
This is not supported. Please delete the build directory and reconfigure.
]])
endif()

CMAKE_DEPENDENT_OPTION(VCPKG_MANIFEST_INSTALL [[
Install the dependencies listed in your manifest:
    If this is off, you will have to manually install your dependencies.
    See https://github.com/microsoft/vcpkg/tree/master/docs/specifications/manifests.md for more info.
]]
    ON
    "VCPKG_MANIFEST_MODE"
    OFF)

if(VCPKG_MANIFEST_INSTALL)
    set(VCPKG_BOOTSTRAP_OPTIONS "${VCPKG_BOOTSTRAP_OPTIONS}" CACHE STRING "Additional options to bootstrap vcpkg" FORCE)
    set(VCPKG_OVERLAY_PORTS "${VCPKG_OVERLAY_PORTS}" CACHE STRING "Overlay ports to use for vcpkg install in manifest mode" FORCE)
    set(VCPKG_OVERLAY_TRIPLETS "${VCPKG_OVERLAY_TRIPLETS}" CACHE STRING "Overlay triplets to use for vcpkg install in manifest mode" FORCE)
    set(VCPKG_INSTALL_OPTIONS "${VCPKG_INSTALL_OPTIONS}" CACHE STRING "Additional install options to pass to vcpkg" FORCE)
    set(Z_VCPKG_UNUSED VCPKG_BOOTSTRAP_OPTIONS)
    set(Z_VCPKG_UNUSED VCPKG_OVERLAY_PORTS)
    set(Z_VCPKG_UNUSED VCPKG_OVERLAY_TRIPLETS)
    set(Z_VCPKG_UNUSED VCPKG_INSTALL_OPTIONS)
endif()

# CMake helper utilities

#[===[.md:
# z_vcpkg_function_arguments

Get a list of the arguments which were passed in.
Unlike `ARGV`, which is simply the arguments joined with `;`,
so that `(A B)` is not distinguishable from `("A;B")`,
this macro gives `"A;B"` for the first argument list,
and `"A\;B"` for the second.

```cmake
z_vcpkg_function_arguments(<out-var> [<N>])
```

`z_vcpkg_function_arguments` gets the arguments between `ARGV<N>` and the last argument.
`<N>` defaults to `0`, so that all arguments are taken.

## Example:
```cmake
function(foo_replacement)
    z_vcpkg_function_arguments(ARGS)
    foo(${ARGS})
    ...
endfunction()
```
#]===]

# NOTE: this function definition is copied directly from scripts/cmake/z_vcpkg_function_arguments.cmake
# do not make changes here without making the same change there.
macro(z_vcpkg_function_arguments OUT_VAR)
    if("${ARGC}" EQUAL 1)
        set(z_vcpkg_function_arguments_FIRST_ARG 0)
    elseif("${ARGC}" EQUAL 2)
        set(z_vcpkg_function_arguments_FIRST_ARG "${ARGV1}")
    else()
        # vcpkg bug
        message(FATAL_ERROR "z_vcpkg_function_arguments: invalid arguments (${ARGV})")
    endif()

    set("${OUT_VAR}")

    # this allows us to get the value of the enclosing function's ARGC
    set(z_vcpkg_function_arguments_ARGC_NAME "ARGC")
    set(z_vcpkg_function_arguments_ARGC "${${z_vcpkg_function_arguments_ARGC_NAME}}")

    math(EXPR z_vcpkg_function_arguments_LAST_ARG "${z_vcpkg_function_arguments_ARGC} - 1")
    # GREATER_EQUAL added in CMake 3.7
    if(NOT z_vcpkg_function_arguments_LAST_ARG LESS z_vcpkg_function_arguments_FIRST_ARG)
        foreach(z_vcpkg_function_arguments_N RANGE "${z_vcpkg_function_arguments_FIRST_ARG}" "${z_vcpkg_function_arguments_LAST_ARG}")
            string(REPLACE ";" "\\;" z_vcpkg_function_arguments_ESCAPED_ARG "${ARGV${z_vcpkg_function_arguments_N}}")
            list(APPEND "${OUT_VAR}" "${z_vcpkg_function_arguments_ESCAPED_ARG}")
        endforeach()
    endif()
endmacro()

#[===[.md:
# z_vcpkg_*_parent_scope_export
If you need to re-export variables to a parent scope from a call,
you can put these around the call to re-export those variables that have changed locally
to parent scope.

## Usage:
```cmake
z_vcpkg_start_parent_scope_export(
    [PREFIX <PREFIX>]
)
z_vcpkg_complete_parent_scope_export(
    [PREFIX <PREFIX>]
    [IGNORE_REGEX <REGEX>]
)
```

## Parameters
### PREFIX
The prefix to use to store the old variable values; defaults to `Z_VCPKG_PARENT_SCOPE_EXPORT`.
The value of each variable `<VAR>` will be stored in `${PREFIX}_<VAR>` by `start`,
and then every variable which is different from `${PREFIX}_VAR` will be re-exported by `complete`.

### IGNORE_REGEX
Variables with names matching this regex will not be exported even if their value has changed.

## Example:
```cmake
z_vcpkg_start_parent_scope_export()
_find_package(blah)
z_vcpkg_complete_parent_scope_export()
```
#]===]
# Notes: these do not use `cmake_parse_arguments` in order to support older versions of cmake,
# pre-3.7 and PARSE_ARGV
macro(z_vcpkg_start_parent_scope_export)
    if("${ARGC}" EQUAL "0")
        set(z_vcpkg_parent_scope_export_PREFIX "Z_VCPKG_PARENT_SCOPE_EXPORT")
    elseif("${ARGC}" EQUAL "2" AND "${ARGV0}" STREQUAL "PREFIX")
        set(z_vcpkg_parent_scope_export_PREFIX "${ARGV1}")
    else()
        message(FATAL_ERROR "Invalid parameters to z_vcpkg_start_parent_scope_export: (${ARGV})")
    endif()
    get_property(z_vcpkg_parent_scope_export_VARIABLE_LIST
        DIRECTORY PROPERTY "VARIABLES")
    foreach(z_vcpkg_parent_scope_export_VARIABLE IN LISTS z_vcpkg_parent_scope_export_VARIABLE_LIST)
        set("${z_vcpkg_parent_scope_export_PREFIX}_${z_vcpkg_parent_scope_export_VARIABLE}" "${${z_vcpkg_parent_scope_export_VARIABLE}}")
    endforeach()
endmacro()

macro(z_vcpkg_complete_parent_scope_export)
    set(z_vcpkg_parent_scope_export_PREFIX_FILLED OFF)
    if("${ARGC}" EQUAL "0")
        # do nothing, replace with default values
    elseif("${ARGC}" EQUAL "2")
        if("${ARGV0}" STREQUAL "PREFIX")
            set(z_vcpkg_parent_scope_export_PREFIX_FILLED ON)
            set(z_vcpkg_parent_scope_export_PREFIX "${ARGV1}")
        elseif("${ARGV0}" STREQUAL "IGNORE_REGEX")
            set(z_vcpkg_parent_scope_export_IGNORE_REGEX "${ARGV1}")
        else()
            message(FATAL_ERROR "Invalid arguments to z_vcpkg_complete_parent_scope_export: (${ARGV})")
        endif()
    elseif("${ARGC}" EQUAL "4")
        if("${ARGV0}" STREQUAL "PREFIX" AND "${ARGV2}" STREQUAL "IGNORE_REGEX")
            set(z_vcpkg_parent_scope_export_PREFIX_FILLED ON)
            set(z_vcpkg_parent_scope_export_PREFIX "${ARGV1}")
            set(z_vcpkg_parent_scope_export_IGNORE_REGEX "${ARGV3}")
        elseif("${ARGV0}" STREQUAL "IGNORE_REGEX" AND "${ARGV2}" STREQUAL "PREFIX")
            set(z_vcpkg_parent_scope_export_IGNORE_REGEX "${ARGV1}")
            set(z_vcpkg_parent_scope_export_PREFIX_FILLED ON)
            set(z_vcpkg_parent_scope_export_PREFIX "${ARGV3}")
        else()
            message(FATAL_ERROR "Invalid arguments to z_vcpkg_start_parent_scope_export: (${ARGV})")
        endif()
    else()
        message(FATAL_ERROR "Invalid arguments to z_vcpkg_complete_parent_scope_export: (${ARGV})")
    endif()

    if(NOT z_vcpkg_parent_scope_export_PREFIX)
        set(z_vcpkg_parent_scope_export_PREFIX "Z_VCPKG_PARENT_SCOPE_EXPORT")
    endif()

    get_property(z_vcpkg_parent_scope_export_VARIABLE_LIST
        DIRECTORY PROPERTY "VARIABLES")
    foreach(z_vcpkg_parent_scope_export_VARIABLE IN LISTS z_vcpkg_parent_scope_export_VARIABLE_LIST)
        if("${z_vcpkg_parent_scope_export_VARIABLE}" MATCHES "^${z_vcpkg_parent_scope_export_PREFIX}_")
            # skip the backup variables
            continue()
        endif()
        if("${z_vcpkg_parent_scope_export_VARIABLE}" MATCHES "^${z_vcpkg_parent_scope_export_PREFIX}_")
            # skip the backup variables
            continue()
        endif()

        if(DEFINED "${z_vcpkg_parent_scope_export_IGNORE_REGEX}" AND "${z_vcpkg_parent_scope_export_VARIABLE}" MATCHES "${z_vcpkg_parent_scope_export_IGNORE_REGEX}")
            # skip those variables which should be ignored
            continue()
        endif()

        if(NOT "${${z_vcpkg_parent_scope_export_PREFIX}_${z_vcpkg_parent_scope_export_VARIABLE}}" STREQUAL "${${z_vcpkg_parent_scope_export_VARIABLE}}")
            set("${z_vcpkg_parent_scope_export_VARIABLE}" "${${z_vcpkg_parent_scope_export_VARIABLE}}" PARENT_SCOPE)
        endif()
    endforeach()
endmacro()

#[===[.md:
# z_vcpkg_set_powershell_path

Gets either the path to powershell or powershell core,
and places it in the variable Z_VCPKG_POWERSHELL_PATH.
#]===]
function(z_vcpkg_set_powershell_path)
    # Attempt to use pwsh if it is present; otherwise use powershell
    if(NOT DEFINED Z_VCPKG_POWERSHELL_PATH)
        find_program(Z_VCPKG_PWSH_PATH pwsh)
        if(Z_VCPKG_PWSH_PATH)
            set(Z_VCPKG_POWERSHELL_PATH "${Z_VCPKG_PWSH_PATH}" CACHE INTERNAL "The path to the PowerShell implementation to use.")
        else()
            message(DEBUG "vcpkg: Could not find PowerShell Core; falling back to PowerShell")
            find_program(Z_VCPKG_BUILTIN_POWERSHELL_PATH powershell REQUIRED)
            if(Z_VCPKG_BUILTIN_POWERSHELL_PATH)
                set(Z_VCPKG_POWERSHELL_PATH "${Z_VCPKG_BUILTIN_POWERSHELL_PATH}" CACHE INTERNAL "The path to the PowerShell implementation to use.")
            else()
                message(WARNING "vcpkg: Could not find PowerShell; using static string 'powershell.exe'")
                set(Z_VCPKG_POWERSHELL_PATH "powershell.exe" CACHE INTERNAL "The path to the PowerShell implementation to use.")
            endif()
        endif()
    endif() # Z_VCPKG_POWERSHELL_PATH
endfunction()


# Determine whether the toolchain is loaded during a try-compile configuration
get_property(Z_VCPKG_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)

if(CMAKE_VERSION VERSION_LESS "3.6.0")
    set(Z_VCPKG_CMAKE_EMULATE_TRY_COMPILE_PLATFORM_VARIABLES ON)
else()
    set(Z_VCPKG_CMAKE_EMULATE_TRY_COMPILE_PLATFORM_VARIABLES OFF)
endif()

if(Z_VCPKG_CMAKE_IN_TRY_COMPILE AND Z_VCPKG_CMAKE_EMULATE_TRY_COMPILE_PLATFORM_VARIABLES)
    include("${CMAKE_CURRENT_SOURCE_DIR}/../vcpkg.config.cmake" OPTIONAL)
endif()

if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
endif()

if(VCPKG_TOOLCHAIN)
    cmake_policy(POP)
    return()
endif()

#If CMake does not have a mapping for MinSizeRel and RelWithDebInfo in imported targets
#it will map those configuration to the first valid configuration in CMAKE_CONFIGURATION_TYPES or the targets IMPORTED_CONFIGURATIONS.
#In most cases this is the debug configuration which is wrong.
if(NOT DEFINED CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL)
    set(CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL "MinSizeRel;Release;")
    if(VCPKG_VERBOSE)
        message(STATUS "VCPKG-Info: CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL set to MinSizeRel;Release;")
    endif()
endif()
if(NOT DEFINED CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO)
    set(CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO "RelWithDebInfo;Release;")
    if(VCPKG_VERBOSE)
        message(STATUS "VCPKG-Info: CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO set to RelWithDebInfo;Release;")
    endif()
endif()

if(VCPKG_TARGET_TRIPLET)
    # This is required since a user might do: 'set(VCPKG_TARGET_TRIPLET somevalue)' [no CACHE] before the first project() call
    # Latter within the toolchain file we do: 'set(VCPKG_TARGET_TRIPLET somevalue CACHE STRING "")' which
    # will otherwise override the user setting of VCPKG_TARGET_TRIPLET in the current scope of the toolchain since the CACHE value
    # did not exist previously. Since the value is newly created CMake will use the CACHE value within this scope since it is the more
    # recently created value in directory scope. This 'strange' behaviour only happens on the very first configure call since subsequent
    # configure call will see the user value as the more recent value. The same logic must be applied to all cache values within this file!
    # The FORCE keyword is required to ALWAYS lift the user provided/previously set value into a CACHE value.
    set(VCPKG_TARGET_TRIPLET "${VCPKG_TARGET_TRIPLET}" CACHE STRING "Vcpkg target triplet (ex. x86-windows)" FORCE)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Ww][Ii][Nn]32$")
    set(Z_VCPKG_TARGET_TRIPLET_ARCH x86)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Xx]64$")
    set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]$")
    set(Z_VCPKG_TARGET_TRIPLET_ARCH arm)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]64$")
    set(Z_VCPKG_TARGET_TRIPLET_ARCH arm64)
else()
    if(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 Win64$")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 ARM$")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH arm)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015$")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x86)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 Win64$")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 ARM$")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH arm)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017$")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x86)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 16 2019$")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
    else()
        find_program(Z_VCPKG_CL cl)
        if(Z_VCPKG_CL MATCHES "amd64/cl.exe$" OR Z_VCPKG_CL MATCHES "x64/cl.exe$")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
        elseif(Z_VCPKG_CL MATCHES "arm/cl.exe$")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH arm)
        elseif(Z_VCPKG_CL MATCHES "arm64/cl.exe$")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH arm64)
        elseif(Z_VCPKG_CL MATCHES "bin/cl.exe$" OR Z_VCPKG_CL MATCHES "x86/cl.exe$")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH x86)
        elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin" AND DEFINED CMAKE_SYSTEM_NAME AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            list(LENGTH CMAKE_OSX_ARCHITECTURES Z_VCPKG_OSX_ARCH_COUNT)
            if(Z_VCPKG_OSX_ARCH_COUNT EQUAL 0)
                message(WARNING "Unable to determine target architecture. "
                                "Consider providing a value for the CMAKE_OSX_ARCHITECTURES cache variable. "
                                "Continuing without vcpkg.")
                set(VCPKG_TOOLCHAIN ON)
                cmake_policy(POP)
                return()
            endif()

            if(Z_VCPKG_OSX_ARCH_COUNT GREATER 1)
                message(WARNING "Detected more than one target architecture. Using the first one.")
            endif()
            list(GET CMAKE_OSX_ARCHITECTURES 0 Z_VCPKG_OSX_TARGET_ARCH)
            if(Z_VCPKG_OSX_TARGET_ARCH STREQUAL "arm64")
                set(Z_VCPKG_TARGET_TRIPLET_ARCH arm64)
            elseif(Z_VCPKG_OSX_TARGET_ARCH STREQUAL "arm64s")
                set(Z_VCPKG_TARGET_TRIPLET_ARCH arm64s)
            elseif(Z_VCPKG_OSX_TARGET_ARCH STREQUAL "armv7s")
                set(Z_VCPKG_TARGET_TRIPLET_ARCH armv7s)
            elseif(Z_VCPKG_OSX_TARGET_ARCH STREQUAL "armv7")
                set(Z_VCPKG_TARGET_TRIPLET_ARCH arm)
            elseif(Z_VCPKG_OSX_TARGET_ARCH STREQUAL "x86_64")
                set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
            elseif(Z_VCPKG_OSX_TARGET_ARCH STREQUAL "i386")
                set(Z_VCPKG_TARGET_TRIPLET_ARCH x86)
            else()
                message(WARNING "Unable to determine target architecture, continuing without vcpkg.")
                set(VCPKG_TOOLCHAIN ON)
                cmake_policy(POP)
                return()
            endif()
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64" OR CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "AMD64")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "s390x")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH s390x)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "ppc64le")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH ppc64le)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "armv7l")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH arm)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "aarch64")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH arm64)
        else()
            if(Z_VCPKG_CMAKE_IN_TRY_COMPILE)
                message(STATUS "Unable to determine target architecture, continuing without vcpkg.")
            else()
                message(WARNING "Unable to determine target architecture, continuing without vcpkg.")
            endif()
            set(VCPKG_TOOLCHAIN ON)
            cmake_policy(POP)
            return()
        endif()
    endif()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsPhone")
    set(Z_VCPKG_TARGET_TRIPLET_PLAT uwp)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"))
    set(Z_VCPKG_TARGET_TRIPLET_PLAT linux)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"))
    set(Z_VCPKG_TARGET_TRIPLET_PLAT osx)
elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(Z_VCPKG_TARGET_TRIPLET_PLAT ios)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
    set(Z_VCPKG_TARGET_TRIPLET_PLAT windows)
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD"))
    set(Z_VCPKG_TARGET_TRIPLET_PLAT freebsd)
endif()

set(VCPKG_TARGET_TRIPLET "${Z_VCPKG_TARGET_TRIPLET_ARCH}-${Z_VCPKG_TARGET_TRIPLET_PLAT}" CACHE STRING "Vcpkg target triplet (ex. x86-windows)")
set(Z_VCPKG_TOOLCHAIN_DIR "${CMAKE_CURRENT_LIST_DIR}")

if(NOT DEFINED Z_VCPKG_ROOT_DIR)
    # Detect .vcpkg-root to figure VCPKG_ROOT_DIR
    set(Z_VCPKG_ROOT_DIR_CANDIDATE "${CMAKE_CURRENT_LIST_DIR}")
    while(IS_DIRECTORY "${Z_VCPKG_ROOT_DIR_CANDIDATE}" AND NOT EXISTS "${Z_VCPKG_ROOT_DIR_CANDIDATE}/.vcpkg-root")
        get_filename_component(Z_VCPKG_ROOT_DIR_TEMP "${Z_VCPKG_ROOT_DIR_CANDIDATE}" DIRECTORY)
        if(Z_VCPKG_ROOT_DIR_TEMP STREQUAL Z_VCPKG_ROOT_DIR_CANDIDATE) # If unchanged, we have reached the root of the drive
        else()
            SET(Z_VCPKG_ROOT_DIR_CANDIDATE "${Z_VCPKG_ROOT_DIR_TEMP}")
        endif()
    endwhile()
    set(Z_VCPKG_ROOT_DIR "${Z_VCPKG_ROOT_DIR_CANDIDATE}" CACHE INTERNAL "Vcpkg root directory")
endif()

if(NOT Z_VCPKG_ROOT_DIR)
    z_vcpkg_add_fatal_error("Could not find .vcpkg-root")
endif()

if(NOT DEFINED _VCPKG_INSTALLED_DIR)
    if(VCPKG_MANIFEST_MODE)
        set(_VCPKG_INSTALLED_DIR "${CMAKE_BINARY_DIR}/vcpkg_installed")
    else()
        set(_VCPKG_INSTALLED_DIR "${Z_VCPKG_ROOT_DIR}/installed")
    endif()
set(_VCPKG_INSTALLED_DIR "${_VCPKG_INSTALLED_DIR}"
    CACHE PATH
    "The directory which contains the installed libraries for each triplet" FORCE)
endif()

if(CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$" OR NOT DEFINED CMAKE_BUILD_TYPE) #Debug build: Put Debug paths before Release paths.
    list(APPEND CMAKE_PREFIX_PATH
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug"
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}"
    )
    list(APPEND CMAKE_LIBRARY_PATH
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link"
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link"
    )
    list(APPEND CMAKE_FIND_ROOT_PATH
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug"
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}"
    )
else() #Release build: Put Release paths before Debug paths. Debug Paths are required so that CMake generates correct info in autogenerated target files.
    list(APPEND CMAKE_PREFIX_PATH
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}"
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug"
    )
    list(APPEND CMAKE_LIBRARY_PATH
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link"
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link"
    )
    list(APPEND CMAKE_FIND_ROOT_PATH
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}"
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug"
    )
endif()

# If one CMAKE_FIND_ROOT_PATH_MODE_* variables is set to ONLY, to  make sure that ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
# and ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug are searched, it is not sufficient to just add them to CMAKE_FIND_ROOT_PATH,
# as CMAKE_FIND_ROOT_PATH specify "one or more directories to be prepended to all other search directories", so to make sure that
# the libraries are searched as they are, it is necessary to add "/" to the CMAKE_PREFIX_PATH
if(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE STREQUAL "ONLY" OR
   CMAKE_FIND_ROOT_PATH_MODE_LIBRARY STREQUAL "ONLY" OR
   CMAKE_FIND_ROOT_PATH_MODE_PACKAGE STREQUAL "ONLY")
   list(APPEND CMAKE_PREFIX_PATH "/")
endif()

set(VCPKG_CMAKE_FIND_ROOT_PATH "${CMAKE_FIND_ROOT_PATH}")

file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" Z_VCPKG_PROGRAMFILES)
set(Z_VCPKG_PROGRAMFILESX86_NAME "PROGRAMFILES(x86)")
file(TO_CMAKE_PATH "$ENV{${Z_VCPKG_PROGRAMFILESX86_NAME}}" Z_VCPKG_PROGRAMFILESX86)
set(CMAKE_SYSTEM_IGNORE_PATH
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win32"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win64"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win32/lib/VC"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win64/lib/VC"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win32/lib/VC/static"
    "${Z_VCPKG_PROGRAMFILES}/OpenSSL-Win64/lib/VC/static"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win32"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win64"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win32/lib/VC"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win64/lib/VC"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win32/lib/VC/static"
    "${Z_VCPKG_PROGRAMFILESX86}/OpenSSL-Win64/lib/VC/static"
    "C:/OpenSSL/"
    "C:/OpenSSL-Win32/"
    "C:/OpenSSL-Win64/"
    "C:/OpenSSL-Win32/lib/VC"
    "C:/OpenSSL-Win64/lib/VC"
    "C:/OpenSSL-Win32/lib/VC/static"
    "C:/OpenSSL-Win64/lib/VC/static"
)

# CMAKE_EXECUTABLE_SUFFIX is not yet defined
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(Z_VCPKG_EXECUTABLE "${Z_VCPKG_ROOT_DIR}/vcpkg.exe")
    set(Z_VCPKG_BOOTSTRAP_SCRIPT "${Z_VCPKG_ROOT_DIR}/bootstrap-vcpkg.bat")
else()
    set(Z_VCPKG_EXECUTABLE "${Z_VCPKG_ROOT_DIR}/vcpkg")
    set(Z_VCPKG_BOOTSTRAP_SCRIPT "${Z_VCPKG_ROOT_DIR}/bootstrap-vcpkg.sh")
endif()

if(VCPKG_MANIFEST_MODE AND VCPKG_MANIFEST_INSTALL AND NOT Z_VCPKG_CMAKE_IN_TRY_COMPILE AND NOT Z_VCPKG_HAS_FATAL_ERROR)
    if(NOT EXISTS "${Z_VCPKG_EXECUTABLE}" AND NOT Z_VCPKG_HAS_FATAL_ERROR)
        message(STATUS "Bootstrapping vcpkg before install")

        file(TO_NATIVE_PATH "${CMAKE_BINARY_DIR}/vcpkg-bootstrap.log" Z_VCPKG_BOOTSTRAP_LOG)
        execute_process(
            COMMAND "${Z_VCPKG_BOOTSTRAP_SCRIPT}" ${VCPKG_BOOTSTRAP_OPTIONS}
            OUTPUT_FILE "${Z_VCPKG_BOOTSTRAP_LOG}"
            ERROR_FILE "${Z_VCPKG_BOOTSTRAP_LOG}"
            RESULT_VARIABLE Z_VCPKG_BOOTSTRAP_RESULT)

        if(Z_VCPKG_BOOTSTRAP_RESULT EQUAL 0)
            message(STATUS "Bootstrapping vcpkg before install - done")
        else()
            message(STATUS "Bootstrapping vcpkg before install - failed")
            z_vcpkg_add_fatal_error("vcpkg install failed. See logs for more information: ${Z_VCPKG_BOOTSTRAP_LOG}")
        endif()
    endif()

    if(NOT Z_VCPKG_HAS_FATAL_ERROR)
        message(STATUS "Running vcpkg install")

        set(Z_VCPKG_ADDITIONAL_MANIFEST_PARAMS)

        if(DEFINED VCPKG_HOST_TRIPLET AND NOT VCPKG_HOST_TRIPLET STREQUAL "")
            list(APPEND Z_VCPKG_ADDITIONAL_MANIFEST_PARAMS "--host-triplet=${VCPKG_HOST_TRIPLET}")
        endif()

        if(VCPKG_OVERLAY_PORTS)
            foreach(Z_VCPKG_OVERLAY_PORT IN LISTS VCPKG_OVERLAY_PORTS)
                list(APPEND Z_VCPKG_ADDITIONAL_MANIFEST_PARAMS "--overlay-ports=${Z_VCPKG_OVERLAY_PORT}")
            endforeach()
        endif()
        if(VCPKG_OVERLAY_TRIPLETS)
            foreach(Z_VCPKG_OVERLAY_TRIPLET IN LISTS VCPKG_OVERLAY_TRIPLETS)
                list(APPEND Z_VCPKG_ADDITIONAL_MANIFEST_PARAMS "--overlay-triplets=${Z_VCPKG_OVERLAY_TRIPLET}")
            endforeach()
        endif()

        if(DEFINED VCPKG_FEATURE_FLAGS OR DEFINED CACHE{VCPKG_FEATURE_FLAGS})
            list(JOIN VCPKG_FEATURE_FLAGS "," Z_VCPKG_FEATURE_FLAGS)
            set(Z_VCPKG_FEATURE_FLAGS "--feature-flags=${Z_VCPKG_FEATURE_FLAGS}")
        endif()

        foreach(Z_VCPKG_FEATURE IN LISTS VCPKG_MANIFEST_FEATURES)
            list(APPEND Z_VCPKG_ADDITIONAL_MANIFEST_PARAMS "--x-feature=${Z_VCPKG_FEATURE}")
        endforeach()

        if(VCPKG_MANIFEST_NO_DEFAULT_FEATURES)
            list(APPEND Z_VCPKG_ADDITIONAL_MANIFEST_PARAMS "--x-no-default-features")
        endif()

        if(NOT CMAKE_VERSION VERSION_LESS "3.18") # == GREATER_EQUAL, but that was added in CMake 3.7
            set(Z_VCPKG_MANIFEST_INSTALL_ECHO_PARAMS ECHO_OUTPUT_VARIABLE ECHO_ERROR_VARIABLE)
        else()
            set(Z_VCPKG_MANIFEST_INSTALL_ECHO_PARAMS)
        endif()

        execute_process(
            COMMAND "${Z_VCPKG_EXECUTABLE}" install
                --triplet "${VCPKG_TARGET_TRIPLET}"
                --vcpkg-root "${Z_VCPKG_ROOT_DIR}"
                "--x-wait-for-lock"
                "--x-manifest-root=${VCPKG_MANIFEST_DIR}"
                "--x-install-root=${_VCPKG_INSTALLED_DIR}"
                "${Z_VCPKG_FEATURE_FLAGS}"
                ${Z_VCPKG_ADDITIONAL_MANIFEST_PARAMS}
                ${VCPKG_INSTALL_OPTIONS}
            OUTPUT_VARIABLE Z_VCPKG_MANIFEST_INSTALL_LOGTEXT
            ERROR_VARIABLE Z_VCPKG_MANIFEST_INSTALL_LOGTEXT
            RESULT_VARIABLE Z_VCPKG_MANIFEST_INSTALL_RESULT
            ${Z_VCPKG_MANIFEST_INSTALL_ECHO_PARAMS}
        )

        file(TO_NATIVE_PATH "${CMAKE_BINARY_DIR}/vcpkg-manifest-install.log" Z_VCPKG_MANIFEST_INSTALL_LOGFILE)
        file(WRITE "${Z_VCPKG_MANIFEST_INSTALL_LOGFILE}" "${Z_VCPKG_MANIFEST_INSTALL_LOGTEXT}")

        if(Z_VCPKG_MANIFEST_INSTALL_RESULT EQUAL 0)
            message(STATUS "Running vcpkg install - done")

            # file(TOUCH) added in CMake 3.12
            file(WRITE "${_VCPKG_INSTALLED_DIR}/.cmakestamp" "")
            set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
                "${VCPKG_MANIFEST_DIR}/vcpkg.json"
                "${_VCPKG_INSTALLED_DIR}/.cmakestamp")
            if(EXISTS "${VCPKG_MANIFEST_DIR}/vcpkg-configuration.json")
                set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
                    "${VCPKG_MANIFEST_DIR}/vcpkg-configuration.json")
            endif()
        else()
            message(STATUS "Running vcpkg install - failed")
            z_vcpkg_add_fatal_error("vcpkg install failed. See logs for more information: ${Z_VCPKG_MANIFEST_INSTALL_LOGFILE}")
        endif()
    endif()
endif()

list(APPEND CMAKE_PROGRAM_PATH "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools")
file(GLOB Z_VCPKG_TOOLS_DIRS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/*")
foreach(Z_VCPKG_TOOLS_DIR IN LISTS Z_VCPKG_TOOLS_DIRS)
    if(IS_DIRECTORY "${Z_VCPKG_TOOLS_DIR}")
        list(APPEND CMAKE_PROGRAM_PATH "${Z_VCPKG_TOOLS_DIR}")
    endif()
endforeach()

function(add_executable)
    z_vcpkg_function_arguments(ARGS)
    _add_executable(${ARGS})
    set(target_name "${ARGV0}")

    list(FIND ARGV "IMPORTED" IMPORTED_IDX)
    list(FIND ARGV "ALIAS" ALIAS_IDX)
    list(FIND ARGV "MACOSX_BUNDLE" MACOSX_BUNDLE_IDX)
    if(IMPORTED_IDX EQUAL -1 AND ALIAS_IDX EQUAL -1)
        if(VCPKG_APPLOCAL_DEPS)
            if(Z_VCPKG_TARGET_TRIPLET_PLAT MATCHES "windows|uwp")
                z_vcpkg_set_powershell_path()
                set(EXTRA_OPTIONS "")
                if(X_VCPKG_APPLOCAL_DEPS_SERIALIZED)
                    set(EXTRA_OPTIONS USES_TERMINAL)
                endif()
                add_custom_command(TARGET "${target_name}" POST_BUILD
                    COMMAND "${Z_VCPKG_POWERSHELL_PATH}" -noprofile -executionpolicy Bypass -file "${Z_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1"
                        -targetBinary "$<TARGET_FILE:${target_name}>"
                        -installedDir "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin"
                        -OutVariable out
                    ${EXTRA_OPTIONS}
                )
            elseif(Z_VCPKG_TARGET_TRIPLET_PLAT MATCHES "osx")
                if(NOT MACOSX_BUNDLE_IDX EQUAL -1)
                    add_custom_command(TARGET "${target_name}" POST_BUILD
                    COMMAND python "${Z_VCPKG_TOOLCHAIN_DIR}/osx/applocal.py"
                        "$<TARGET_FILE:${target_name}>"
                        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>"
                    )
                endif()
            endif()
        endif()
        set_target_properties("${target_name}" PROPERTIES VS_USER_PROPS do_not_import_user.props)
        set_target_properties("${target_name}" PROPERTIES VS_GLOBAL_VcpkgEnabled false)
    endif()
endfunction()

function(add_library)
    z_vcpkg_function_arguments(ARGS)
    _add_library(${ARGS})
    set(target_name "${ARGV0}")

    list(FIND ARGS "IMPORTED" IMPORTED_IDX)
    list(FIND ARGS "INTERFACE" INTERFACE_IDX)
    list(FIND ARGS "ALIAS" ALIAS_IDX)
    if(IMPORTED_IDX EQUAL -1 AND INTERFACE_IDX EQUAL -1 AND ALIAS_IDX EQUAL -1)
        get_target_property(IS_LIBRARY_SHARED "${target_name}" TYPE)
        if(VCPKG_APPLOCAL_DEPS AND Z_VCPKG_TARGET_TRIPLET_PLAT MATCHES "windows|uwp" AND (IS_LIBRARY_SHARED STREQUAL "SHARED_LIBRARY" OR IS_LIBRARY_SHARED STREQUAL "MODULE_LIBRARY"))
            z_vcpkg_set_powershell_path()
            add_custom_command(TARGET "${target_name}" POST_BUILD
                COMMAND "${Z_VCPKG_POWERSHELL_PATH}" -noprofile -executionpolicy Bypass -file "${Z_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1"
                    -targetBinary "$<TARGET_FILE:${target_name}>"
                    -installedDir "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin"
                    -OutVariable out
            )
        endif()
        set_target_properties("${target_name}" PROPERTIES VS_USER_PROPS do_not_import_user.props)
        set_target_properties("${target_name}" PROPERTIES VS_GLOBAL_VcpkgEnabled false)
    endif()
endfunction()

# This is an experimental function to enable applocal install of dependencies as part of the `make install` process
# Arguments:
#   TARGETS - a list of installed targets to have dependencies copied for
#   DESTINATION - the runtime directory for those targets (usually `bin`)
#
# Note that this function requires CMake 3.14 for policy CMP0087
function(x_vcpkg_install_local_dependencies)
    if(Z_VCPKG_TARGET_TRIPLET_PLAT MATCHES "windows|uwp")
        cmake_parse_arguments(PARSE_ARGV 0 __VCPKG_APPINSTALL "" "DESTINATION" "TARGETS")
        z_vcpkg_set_powershell_path()
        if(NOT IS_ABSOLUTE "${__VCPKG_APPINSTALL_DESTINATION}")
            set(__VCPKG_APPINSTALL_DESTINATION "\${CMAKE_INSTALL_PREFIX}/${__VCPKG_APPINSTALL_DESTINATION}")
        endif()
        foreach(TARGET IN LISTS __VCPKG_APPINSTALL_TARGETS)
            get_target_property(TARGETTYPE "${TARGET}" TYPE)
            if(NOT TARGETTYPE STREQUAL "INTERFACE_LIBRARY")
                # Install CODE|SCRIPT allow the use of generator expressions
                if(POLICY CMP0087)
                    cmake_policy(SET CMP0087 NEW)
                endif()
                install(CODE "message(\"-- Installing app dependencies for ${TARGET}...\")
                    execute_process(COMMAND \"${Z_VCPKG_POWERSHELL_PATH}\" -noprofile -executionpolicy Bypass -file \"${Z_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1\"
                        -targetBinary \"${__VCPKG_APPINSTALL_DESTINATION}/$<TARGET_FILE_NAME:${TARGET}>\"
                        -installedDir \"${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin\"
                        -OutVariable out)")
            endif()
        endforeach()
    endif()
endfunction()

if(X_VCPKG_APPLOCAL_DEPS_INSTALL)
    function(install)
        z_vcpkg_function_arguments(ARGS)
        _install(${ARGS})

        if(ARGV0 STREQUAL "TARGETS")
            # Will contain the list of targets
            set(PARSED_TARGETS "")

            # Destination - [RUNTIME] DESTINATION argument overrides this
            set(DESTINATION "bin")

            # Parse arguments given to the install function to find targets and (runtime) destination
            set(MODIFIER "") # Modifier for the command in the argument
            set(LAST_COMMAND "") # Last command we found to process
            foreach(ARG IN LISTS ARGS)
                if(ARG MATCHES "ARCHIVE|LIBRARY|RUNTIME|OBJECTS|FRAMEWORK|BUNDLE|PRIVATE_HEADER|PUBLIC_HEADER|RESOURCE|INCLUDES")
                    set(MODIFIER "${ARG}")
                    continue()
                endif()
                if(ARG MATCHES "TARGETS|DESTINATION|PERMISSIONS|CONFIGURATIONS|COMPONENT|NAMELINK_COMPONENT|OPTIONAL|EXCLUDE_FROM_ALL|NAMELINK_ONLY|NAMELINK_SKIP|EXPORT")
                    set(LAST_COMMAND "${ARG}")
                    continue()
                endif()

                if(LAST_COMMAND STREQUAL "TARGETS")
                    list(APPEND PARSED_TARGETS "${ARG}")
                endif()

                if(LAST_COMMAND STREQUAL "DESTINATION" AND (MODIFIER STREQUAL "" OR MODIFIER STREQUAL "RUNTIME"))
                    set(DESTINATION "${ARG}")
                endif()
            endforeach()

            x_vcpkg_install_local_dependencies(TARGETS "${PARSED_TARGETS}" DESTINATION "${DESTINATION}")
        endif()
    endfunction()
endif()

if(NOT DEFINED VCPKG_OVERRIDE_FIND_PACKAGE_NAME)
    set(VCPKG_OVERRIDE_FIND_PACKAGE_NAME find_package)
endif()
function("${VCPKG_OVERRIDE_FIND_PACKAGE_NAME}")
    # Workaround to set the ROOT_PATH until upstream CMake stops overriding
    # the ROOT_PATH at apple OS initialization phase.
    # See https://gitlab.kitware.com/cmake/cmake/merge_requests/3273
    if(CMAKE_SYSTEM_NAME STREQUAL iOS)
        # this is not a mutating operation,
        # this just creates a new variable named CMAKE_FIND_ROOT_PATH with value
        # "${CMAKE_FIND_ROOT_PATH};${VCPKG_CMAKE_FIND_ROOT_PATH}"
        # therefore, we don't have to worry about restoring its old value
        list(APPEND CMAKE_FIND_ROOT_PATH "${VCPKG_CMAKE_FIND_ROOT_PATH}")
    endif()
    z_vcpkg_function_arguments(ARGS)
    set(PACKAGE_NAME "${ARGV0}")
    string(TOLOWER "${PACKAGE_NAME}" LOWERCASE_PACKAGE_NAME)

    set(VCPKG_CMAKE_WRAPPER_PATH "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/${LOWERCASE_PACKAGE_NAME}/vcpkg-cmake-wrapper.cmake")

    z_vcpkg_start_parent_scope_export()
    if(EXISTS "${VCPKG_CMAKE_WRAPPER_PATH}")
        include("${VCPKG_CMAKE_WRAPPER_PATH}")
    elseif("${PACKAGE_NAME}" STREQUAL "Boost" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/boost")
        # Checking for the boost headers disables this wrapper unless the user has installed at least one boost library
        set(Boost_USE_STATIC_LIBS OFF)
        set(Boost_USE_MULTITHREADED ON)
        unset(Boost_USE_STATIC_RUNTIME)
        set(Boost_NO_BOOST_CMAKE ON)
        unset(Boost_USE_STATIC_RUNTIME CACHE)
        if("${CMAKE_VS_PLATFORM_TOOLSET}" STREQUAL "v120")
            set(Boost_COMPILER "-vc120")
        else()
            set(Boost_COMPILER "-vc140")
        endif()
        _find_package(${ARGS})
    elseif("${PACKAGE_NAME}" STREQUAL "ICU" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/unicode/utf.h")
        list(FIND ARGS "COMPONENTS" COMPONENTS_IDX)
        if(NOT COMPONENTS_IDX EQUAL -1)
            _find_package(${ARGS} COMPONENTS data)
        else()
            _find_package(${ARGS})
        endif()
    elseif("${PACKAGE_NAME}" STREQUAL "GSL" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/gsl")
        _find_package(${ARGS})
        if(GSL_FOUND AND TARGET GSL::gsl)
            set_property( TARGET GSL::gslcblas APPEND PROPERTY IMPORTED_CONFIGURATIONS Release )
            set_property( TARGET GSL::gsl APPEND PROPERTY IMPORTED_CONFIGURATIONS Release )
            if( EXISTS "${GSL_LIBRARY_DEBUG}" AND EXISTS "${GSL_CBLAS_LIBRARY_DEBUG}")
                set_property( TARGET GSL::gsl APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
                set_target_properties( GSL::gsl PROPERTIES IMPORTED_LOCATION_DEBUG "${GSL_LIBRARY_DEBUG}" )
                set_property( TARGET GSL::gslcblas APPEND PROPERTY IMPORTED_CONFIGURATIONS Debug )
                set_target_properties( GSL::gslcblas PROPERTIES IMPORTED_LOCATION_DEBUG "${GSL_CBLAS_LIBRARY_DEBUG}" )
            endif()
        endif()
    elseif("${PACKAGE_NAME}" STREQUAL "CURL" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/curl")
        _find_package(${ARGS})
        if(CURL_FOUND)
            if(EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/nghttp2.lib")
                list(APPEND CURL_LIBRARIES
                    "debug" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/nghttp2.lib"
                    "optimized" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/nghttp2.lib")
            endif()
        endif()
    elseif("${LOWERCASE_PACKAGE_NAME}" STREQUAL "grpc" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/grpc")
        list(REMOVE_AT ARGS 0)
        _find_package(gRPC ${ARGS})
    else()
        _find_package(${ARGS})
    endif()

    z_vcpkg_complete_parent_scope_export(IGNORE_REGEX "(^Z_VCPKG_)|(^ARGS$)|(^COMPONENTS_IDX$)")
endfunction()

set(VCPKG_TOOLCHAIN ON)
set(Z_VCPKG_UNUSED "${CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION}")
set(Z_VCPKG_UNUSED "${CMAKE_EXPORT_NO_PACKAGE_REGISTRY}")
set(Z_VCPKG_UNUSED "${CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY}")
set(Z_VCPKG_UNUSED "${CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY}")
set(Z_VCPKG_UNUSED "${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP}")

# Propogate these values to try-compile configurations so the triplet and toolchain load
if(NOT Z_VCPKG_CMAKE_IN_TRY_COMPILE)
    if(Z_VCPKG_CMAKE_EMULATE_TRY_COMPILE_PLATFORM_VARIABLES)
        file(TO_CMAKE_PATH "${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}" Z_VCPKG_CHAINLOAD_FILE_CMAKE)
        file(TO_CMAKE_PATH "${Z_VCPKG_ROOT_DIR}" Z_VCPKG_ROOT_DIR_CMAKE)
        file(WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/vcpkg.config.cmake"
            "set(VCPKG_TARGET_TRIPLET \"${VCPKG_TARGET_TRIPLET}\" CACHE STRING \"\")\n"
            "set(VCPKG_TARGET_ARCHITECTURE \"${VCPKG_TARGET_ARCHITECTURE}\" CACHE STRING \"\")\n"
            "set(VCPKG_APPLOCAL_DEPS \"${VCPKG_APPLOCAL_DEPS}\" CACHE STRING \"\")\n"
            "set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE \"${Z_VCPKG_CHAINLOAD_FILE_CMAKE}\" CACHE STRING \"\")\n"
            "set(Z_VCPKG_ROOT_DIR \"${Z_VCPKG_ROOT_DIR_CMAKE}\" CACHE STRING \"\")\n"
        )
    else()
        list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
            VCPKG_TARGET_TRIPLET
            VCPKG_TARGET_ARCHITECTURE
            VCPKG_APPLOCAL_DEPS
            VCPKG_CHAINLOAD_TOOLCHAIN_FILE
            Z_VCPKG_ROOT_DIR
        )
    endif()
endif()

if(Z_VCPKG_HAS_FATAL_ERROR)
    message(FATAL_ERROR "${Z_VCPKG_FATAL_ERROR}")
endif()

cmake_policy(POP)
