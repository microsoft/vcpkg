# Mark variables as used so cmake doesn't complain about them
mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

# NOTE: to figure out what cmake versions are required for different things,
# grep for `CMake 3`. All version requirement comments should follow that format.

# Attention: Changes to this file do not affect ABI hashing.

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

set(Z_VCPKG_CMAKE_REQUIRED_MINIMUM_VERSION "3.7.2")
if(CMAKE_VERSION VERSION_LESS Z_VCPKG_CMAKE_REQUIRED_MINIMUM_VERSION)
    message(FATAL_ERROR "vcpkg.cmake requires at least CMake ${Z_VCPKG_CMAKE_REQUIRED_MINIMUM_VERSION}.")
endif()
cmake_policy(PUSH)
cmake_policy(VERSION 3.7.2)

include(CMakeDependentOption)

# VCPKG toolchain options.
option(VCPKG_VERBOSE "Enables messages from the VCPKG toolchain for debugging purposes." OFF)
mark_as_advanced(VCPKG_VERBOSE)

option(VCPKG_APPLOCAL_DEPS "Automatically copy dependencies into the output directory for executables." ON)
option(X_VCPKG_APPLOCAL_DEPS_SERIALIZED "(experimental) Add USES_TERMINAL to VCPKG_APPLOCAL_DEPS to force serialization." OFF)

# requires CMake 3.14
option(X_VCPKG_APPLOCAL_DEPS_INSTALL "(experimental) Automatically copy dependencies into the install target directory for executables. Requires CMake 3.14." OFF)
option(VCPKG_PREFER_SYSTEM_LIBS "Appends the vcpkg paths to CMAKE_PREFIX_PATH, CMAKE_LIBRARY_PATH and CMAKE_FIND_ROOT_PATH so that vcpkg libraries/packages are found after toolchain/system libraries/packages." OFF)

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

    set("${OUT_VAR}" "")

    # this allows us to get the value of the enclosing function's ARGC
    set(z_vcpkg_function_arguments_ARGC_NAME "ARGC")
    set(z_vcpkg_function_arguments_ARGC "${${z_vcpkg_function_arguments_ARGC_NAME}}")

    math(EXPR z_vcpkg_function_arguments_LAST_ARG "${z_vcpkg_function_arguments_ARGC} - 1")
    # GREATER_EQUAL added in CMake 3.7
    if(NOT z_vcpkg_function_arguments_LAST_ARG LESS z_vcpkg_function_arguments_FIRST_ARG)
        foreach(z_vcpkg_function_arguments_N RANGE "${z_vcpkg_function_arguments_FIRST_ARG}" "${z_vcpkg_function_arguments_LAST_ARG}")
            string(REPLACE ";" "\\;" z_vcpkg_function_arguments_ESCAPED_ARG "${ARGV${z_vcpkg_function_arguments_N}}")
            # adds an extra `;` on the first time through
            set("${OUT_VAR}" "${${OUT_VAR}};${z_vcpkg_function_arguments_ESCAPED_ARG}")
        endforeach()
        # remove leading `;`
        string(SUBSTRING "${${OUT_VAR}}" 1 -1 "${OUT_VAR}")
    endif()
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
    if(CMAKE_GENERATOR STREQUAL "Visual Studio 14 2015 Win64")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR STREQUAL "Visual Studio 14 2015 ARM")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH arm)
    elseif(CMAKE_GENERATOR STREQUAL "Visual Studio 14 2015")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x86)
    elseif(CMAKE_GENERATOR STREQUAL "Visual Studio 15 2017 Win64")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR STREQUAL "Visual Studio 15 2017 ARM")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH arm)
    elseif(CMAKE_GENERATOR STREQUAL "Visual Studio 15 2017")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x86)
    elseif(CMAKE_GENERATOR STREQUAL "Visual Studio 16 2019")
        set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR STREQUAL "Visual Studio 17 2022")
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
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64" OR
               CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "AMD64" OR
               CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "amd64")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH x64)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "s390x")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH s390x)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "ppc64le")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH ppc64le)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "armv7l")
            set(Z_VCPKG_TARGET_TRIPLET_ARCH arm)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
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
elseif(MINGW)
    set(Z_VCPKG_TARGET_TRIPLET_PLAT mingw-dynamic)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
    set(Z_VCPKG_TARGET_TRIPLET_PLAT windows)
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD"))
    set(Z_VCPKG_TARGET_TRIPLET_PLAT freebsd)
endif()

if(EMSCRIPTEN)
    set(Z_VCPKG_TARGET_TRIPLET_ARCH wasm32)
    set(Z_VCPKG_TARGET_TRIPLET_PLAT emscripten)
endif()

set(VCPKG_TARGET_TRIPLET "${Z_VCPKG_TARGET_TRIPLET_ARCH}-${Z_VCPKG_TARGET_TRIPLET_PLAT}" CACHE STRING "Vcpkg target triplet (ex. x86-windows)")
set(Z_VCPKG_TOOLCHAIN_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Detect .vcpkg-root to figure VCPKG_ROOT_DIR
set(Z_VCPKG_ROOT_DIR_CANDIDATE "${CMAKE_CURRENT_LIST_DIR}")
while(NOT DEFINED Z_VCPKG_ROOT_DIR)
    if(EXISTS "${Z_VCPKG_ROOT_DIR_CANDIDATE}/.vcpkg-root")
        set(Z_VCPKG_ROOT_DIR "${Z_VCPKG_ROOT_DIR_CANDIDATE}" CACHE INTERNAL "Vcpkg root directory")
    elseif(IS_DIRECTORY "${Z_VCPKG_ROOT_DIR_CANDIDATE}")
        get_filename_component(Z_VCPKG_ROOT_DIR_TEMP "${Z_VCPKG_ROOT_DIR_CANDIDATE}" DIRECTORY)
        if(Z_VCPKG_ROOT_DIR_TEMP STREQUAL Z_VCPKG_ROOT_DIR_CANDIDATE)
            break() # If unchanged, we have reached the root of the drive without finding vcpkg.
        endif()
        SET(Z_VCPKG_ROOT_DIR_CANDIDATE "${Z_VCPKG_ROOT_DIR_TEMP}")
        unset(Z_VCPKG_ROOT_DIR_TEMP)
    else()
        break()
    endif()
endwhile()
unset(Z_VCPKG_ROOT_DIR_CANDIDATE)

if(NOT Z_VCPKG_ROOT_DIR)
    z_vcpkg_add_fatal_error("Could not find .vcpkg-root")
endif()

if(DEFINED VCPKG_INSTALLED_DIR)
    # do nothing
elseif(DEFINED _VCPKG_INSTALLED_DIR)
    set(VCPKG_INSTALLED_DIR "${_VCPKG_INSTALLED_DIR}")
elseif(VCPKG_MANIFEST_MODE)
    set(VCPKG_INSTALLED_DIR "${CMAKE_BINARY_DIR}/vcpkg_installed")
else()
    set(VCPKG_INSTALLED_DIR "${Z_VCPKG_ROOT_DIR}/installed")
endif()

set(VCPKG_INSTALLED_DIR "${VCPKG_INSTALLED_DIR}"
    CACHE PATH
    "The directory which contains the installed libraries for each triplet" FORCE)
set(_VCPKG_INSTALLED_DIR "${VCPKG_INSTALLED_DIR}"
    CACHE PATH
    "The directory which contains the installed libraries for each triplet" FORCE)

function(z_vcpkg_add_vcpkg_to_cmake_path list suffix)
    set(vcpkg_paths
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}${suffix}"
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug${suffix}"
    )
    if(NOT DEFINED CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$")
        list(REVERSE vcpkg_paths) # Debug build: Put Debug paths before Release paths.
    endif()
    if(VCPKG_PREFER_SYSTEM_LIBS)
        list(APPEND "${list}" "${vcpkg_paths}")
    else()
        list(INSERT "${list}" 0 "${vcpkg_paths}") # CMake 3.15 is required for list(PREPEND ...).
    endif()
    set("${list}" "${${list}}" PARENT_SCOPE)
endfunction()
z_vcpkg_add_vcpkg_to_cmake_path(CMAKE_PREFIX_PATH "")
z_vcpkg_add_vcpkg_to_cmake_path(CMAKE_LIBRARY_PATH "/lib/manual-link")
z_vcpkg_add_vcpkg_to_cmake_path(CMAKE_FIND_ROOT_PATH "")

if(NOT VCPKG_PREFER_SYSTEM_LIBS)
    set(CMAKE_FIND_FRAMEWORK "LAST") # we assume that frameworks are usually system-wide libs, not vcpkg-built
    set(CMAKE_FIND_APPBUNDLE "LAST") # we assume that appbundles are usually system-wide libs, not vcpkg-built
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
            set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
                "${VCPKG_MANIFEST_DIR}/vcpkg.json")
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

option(VCPKG_SETUP_CMAKE_PROGRAM_PATH  "Enable the setup of CMAKE_PROGRAM_PATH to vcpkg paths" ON)
set(VCPKG_CAN_USE_HOST_TOOLS OFF)
if(DEFINED VCPKG_HOST_TRIPLET AND NOT VCPKG_HOST_TRIPLET STREQUAL "")
    set(VCPKG_CAN_USE_HOST_TOOLS ON)
endif()
cmake_dependent_option(VCPKG_USE_HOST_TOOLS "Setup CMAKE_PROGRAM_PATH to use host tools" ON "VCPKG_CAN_USE_HOST_TOOLS" OFF)
unset(VCPKG_CAN_USE_HOST_TOOLS)

if(VCPKG_SETUP_CMAKE_PROGRAM_PATH)
    set(tools_base_path "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools")
    if(VCPKG_USE_HOST_TOOLS)
        set(tools_base_path "${VCPKG_INSTALLED_DIR}/${VCPKG_HOST_TRIPLET}/tools")
    endif()
    list(APPEND CMAKE_PROGRAM_PATH "${tools_base_path}")
    file(GLOB Z_VCPKG_TOOLS_DIRS LIST_DIRECTORIES true "${tools_base_path}/*")
    file(GLOB Z_VCPKG_TOOLS_FILES LIST_DIRECTORIES false "${tools_base_path}/*")
    file(GLOB Z_VCPKG_TOOLS_DIRS_BIN LIST_DIRECTORIES true "${tools_base_path}/*/bin")
    file(GLOB Z_VCPKG_TOOLS_FILES_BIN LIST_DIRECTORIES false "${tools_base_path}/*/bin")
    list(REMOVE_ITEM Z_VCPKG_TOOLS_DIRS ${Z_VCPKG_TOOLS_FILES} "") # need at least one item for REMOVE_ITEM if CMake <= 3.19
    list(REMOVE_ITEM Z_VCPKG_TOOLS_DIRS_BIN ${Z_VCPKG_TOOLS_FILES_BIN} "")
    string(REPLACE "/bin" "" Z_VCPKG_TOOLS_DIRS_TO_REMOVE "${Z_VCPKG_TOOLS_DIRS_BIN}")
    list(REMOVE_ITEM Z_VCPKG_TOOLS_DIRS ${Z_VCPKG_TOOLS_DIRS_TO_REMOVE} "")
    list(APPEND Z_VCPKG_TOOLS_DIRS ${Z_VCPKG_TOOLS_DIRS_BIN})
    foreach(Z_VCPKG_TOOLS_DIR IN LISTS Z_VCPKG_TOOLS_DIRS)
        list(APPEND CMAKE_PROGRAM_PATH "${Z_VCPKG_TOOLS_DIR}")
    endforeach()
    unset(Z_VCPKG_TOOLS_DIR)
    unset(Z_VCPKG_TOOLS_DIRS)
    unset(Z_VCPKG_TOOLS_FILES)
    unset(Z_VCPKG_TOOLS_DIRS_BIN)
    unset(Z_VCPKG_TOOLS_FILES_BIN)
    unset(Z_VCPKG_TOOLS_DIRS_TO_REMOVE)
    unset(tools_base_path)
endif()

cmake_policy(POP)

# Any policies applied to the below macros and functions appear to leak into consumers

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
                    VERBATIM
                    ${EXTRA_OPTIONS}
                )
            elseif(Z_VCPKG_TARGET_TRIPLET_PLAT MATCHES "osx")
                if(NOT MACOSX_BUNDLE_IDX EQUAL -1)
                    add_custom_command(TARGET "${target_name}" POST_BUILD
                        COMMAND python "${Z_VCPKG_TOOLCHAIN_DIR}/osx/applocal.py"
                            "$<TARGET_FILE:${target_name}>"
                            "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>"
                        VERBATIM
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
                    VERBATIM
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
#   COMPONENT - the component this install command belongs to (optional)
#
# Note that this function requires CMake 3.14 for policy CMP0087
function(x_vcpkg_install_local_dependencies)
    if(CMAKE_VERSION VERSION_LESS "3.14")
        message(FATAL_ERROR "x_vcpkg_install_local_dependencies and X_VCPKG_APPLOCAL_DEPS_INSTALL require at least CMake 3.14
(current version: ${CMAKE_VERSION})"
        )
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 arg
        ""
        "DESTINATION;COMPONENT"
        "TARGETS"
    )
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_DESTINATION)
        message(FATAL_ERROR "DESTINATION must be specified")
    endif()

    if(Z_VCPKG_TARGET_TRIPLET_PLAT MATCHES "^(windows|uwp)$")
        # Install CODE|SCRIPT allow the use of generator expressions
        cmake_policy(SET CMP0087 NEW) # CMake 3.14

        z_vcpkg_set_powershell_path()
        if(NOT IS_ABSOLUTE "${arg_DESTINATION}")
            set(arg_DESTINATION "\${CMAKE_INSTALL_PREFIX}/${arg_DESTINATION}")
        endif()

        set(component_param "")
        if(DEFINED arg_COMPONENT)
            set(component_param COMPONENT "${arg_COMPONENT}")
        endif()

        foreach(target IN LISTS arg_TARGETS)
            get_target_property(target_type "${target}" TYPE)
            if(NOT target_type STREQUAL "INTERFACE_LIBRARY")
                install(CODE "message(\"-- Installing app dependencies for ${target}...\")
                    execute_process(COMMAND \"${Z_VCPKG_POWERSHELL_PATH}\" -noprofile -executionpolicy Bypass -file \"${Z_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1\"
                        -targetBinary \"${arg_DESTINATION}/$<TARGET_FILE_NAME:${target}>\"
                        -installedDir \"${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin\"
                        -OutVariable out)"
                    ${component_param}
                )
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
            set(parsed_targets "")

            # Destination - [RUNTIME] DESTINATION argument overrides this
            set(destination "bin")

            set(component_param "")

            # Parse arguments given to the install function to find targets and (runtime) destination
            set(modifier "") # Modifier for the command in the argument
            set(last_command "") # Last command we found to process
            foreach(arg IN LISTS ARGS)
                if(arg MATCHES "^(ARCHIVE|LIBRARY|RUNTIME|OBJECTS|FRAMEWORK|BUNDLE|PRIVATE_HEADER|PUBLIC_HEADER|RESOURCE|INCLUDES)$")
                    set(modifier "${arg}")
                    continue()
                endif()
                if(arg MATCHES "^(TARGETS|DESTINATION|PERMISSIONS|CONFIGURATIONS|COMPONENT|NAMELINK_COMPONENT|OPTIONAL|EXCLUDE_FROM_ALL|NAMELINK_ONLY|NAMELINK_SKIP|EXPORT)$")
                    set(last_command "${arg}")
                    continue()
                endif()

                if(last_command STREQUAL "TARGETS")
                    list(APPEND parsed_targets "${arg}")
                endif()

                if(last_command STREQUAL "DESTINATION" AND (modifier STREQUAL "" OR modifier STREQUAL "RUNTIME"))
                    set(destination "${arg}")
                endif()
                if(last_command STREQUAL "COMPONENT")
                    set(component_param "COMPONENT" "${arg}")
                endif()
            endforeach()

            x_vcpkg_install_local_dependencies(
                TARGETS ${parsed_targets}
                DESTINATION "${destination}"
                ${component_param}
            )
        endif()
    endfunction()
endif()

if(NOT DEFINED VCPKG_OVERRIDE_FIND_PACKAGE_NAME)
    set(VCPKG_OVERRIDE_FIND_PACKAGE_NAME find_package)
endif()
# NOTE: this is not a function, which means that arguments _are not_ perfectly forwarded
# this is fine for `find_package`, since there are no usecases for `;` in arguments,
# so perfect forwarding is not important
macro("${VCPKG_OVERRIDE_FIND_PACKAGE_NAME}" z_vcpkg_find_package_package_name)
    set(z_vcpkg_find_package_package_name "${z_vcpkg_find_package_package_name}")
    set(z_vcpkg_find_package_ARGN "${ARGN}")
    set(z_vcpkg_find_package_backup_vars)

    # Workaround to set the ROOT_PATH until upstream CMake stops overriding
    # the ROOT_PATH at apple OS initialization phase.
    # See https://gitlab.kitware.com/cmake/cmake/merge_requests/3273
    # Fixed in CMake 3.15
    if(CMAKE_SYSTEM_NAME STREQUAL iOS)
        list(APPEND z_vcpkg_find_package_backup_vars "CMAKE_FIND_ROOT_PATH")
        if(DEFINED CMAKE_FIND_ROOT_PATH)
            set(z_vcpkg_find_package_backup_CMAKE_FIND_ROOT_PATH "${CMAKE_FIND_ROOT_PATH}")
        else()
            set(z_vcpkg_find_package_backup_CMAKE_FIND_ROOT_PATH)
        endif()

        list(APPEND CMAKE_FIND_ROOT_PATH "${VCPKG_CMAKE_FIND_ROOT_PATH}")
    endif()
    string(TOLOWER "${z_vcpkg_find_package_package_name}" z_vcpkg_find_package_lowercase_package_name)

    set(z_vcpkg_find_package_vcpkg_cmake_wrapper_path
        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/${z_vcpkg_find_package_lowercase_package_name}/vcpkg-cmake-wrapper.cmake")

    if(EXISTS "${z_vcpkg_find_package_vcpkg_cmake_wrapper_path}")
        list(APPEND z_vcpkg_find_package_backup_vars "ARGS")
        if(DEFINED ARGS)
            set(z_vcpkg_find_package_backup_ARGS "${ARGS}")
        else()
            set(z_vcpkg_find_package_backup_ARGS)
        endif()

        set(ARGS "${z_vcpkg_find_package_package_name};${z_vcpkg_find_package_ARGN}")
        include("${z_vcpkg_find_package_vcpkg_cmake_wrapper_path}")
    elseif(z_vcpkg_find_package_package_name STREQUAL "Boost" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/boost")
        # Checking for the boost headers disables this wrapper unless the user has installed at least one boost library
        # these intentionally are not backed up
        set(Boost_USE_STATIC_LIBS OFF)
        set(Boost_USE_MULTITHREADED ON)
        set(Boost_NO_BOOST_CMAKE ON)
        set(Boost_USE_STATIC_RUNTIME)
        unset(Boost_USE_STATIC_RUNTIME CACHE)
        if(CMAKE_VS_PLATFORM_TOOLSET STREQUAL "v120")
            set(Boost_COMPILER "-vc120")
        else()
            set(Boost_COMPILER "-vc140")
        endif()
        _find_package("${z_vcpkg_find_package_package_name}" ${z_vcpkg_find_package_ARGN})
    elseif(z_vcpkg_find_package_package_name STREQUAL "ICU" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/unicode/utf.h")
        list(FIND z_vcpkg_find_package_ARGN "COMPONENTS" z_vcpkg_find_package_COMPONENTS_IDX)
        if(NOT z_vcpkg_find_package_COMPONENTS_IDX EQUAL -1)
            _find_package("${z_vcpkg_find_package_package_name}" ${z_vcpkg_find_package_ARGN} COMPONENTS data)
        else()
            _find_package("${z_vcpkg_find_package_package_name}" ${z_vcpkg_find_package_ARGN})
        endif()
    elseif(z_vcpkg_find_package_package_name STREQUAL "GSL" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/gsl")
        _find_package("${z_vcpkg_find_package_package_name}" ${z_vcpkg_find_package_ARGN})
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
    elseif("${z_vcpkg_find_package_package_name}" STREQUAL "CURL" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/curl")
        _find_package("${z_vcpkg_find_package_package_name}" ${z_vcpkg_find_package_ARGN})
        if(CURL_FOUND)
            if(EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/nghttp2.lib")
                list(APPEND CURL_LIBRARIES
                    "debug" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/nghttp2.lib"
                    "optimized" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/nghttp2.lib")
            endif()
        endif()
    elseif("${z_vcpkg_find_package_lowercase_package_name}" STREQUAL "grpc" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/grpc")
        _find_package(gRPC ${z_vcpkg_find_package_ARGN})
    else()
        _find_package("${z_vcpkg_find_package_package_name}" ${z_vcpkg_find_package_ARGN})
    endif()

    foreach(z_vcpkg_find_package_backup_var IN LISTS z_vcpkg_find_package_backup_vars)
        if(DEFINED z_vcpkg_find_package_backup_${z_vcpkg_find_package_backup_var})
            set("${z_vcpkg_find_package_backup_var}" "${z_vcpkg_find_package_backup_${z_vcpkg_find_package_backup_var}}")
        else()
            set("${z_vcpkg_find_package_backup_var}")
        endif()
    endforeach()
endmacro()

cmake_policy(PUSH)
cmake_policy(VERSION 3.7.2)

set(VCPKG_TOOLCHAIN ON)
set(Z_VCPKG_UNUSED "${CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION}")
set(Z_VCPKG_UNUSED "${CMAKE_EXPORT_NO_PACKAGE_REGISTRY}")
set(Z_VCPKG_UNUSED "${CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY}")
set(Z_VCPKG_UNUSED "${CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY}")
set(Z_VCPKG_UNUSED "${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP}")

# Propogate these values to try-compile configurations so the triplet and toolchain load
if(NOT Z_VCPKG_CMAKE_IN_TRY_COMPILE)
    list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
        VCPKG_TARGET_TRIPLET
        VCPKG_TARGET_ARCHITECTURE
        VCPKG_APPLOCAL_DEPS
        VCPKG_CHAINLOAD_TOOLCHAIN_FILE
        Z_VCPKG_ROOT_DIR
    )
endif()

if(Z_VCPKG_HAS_FATAL_ERROR)
    message(FATAL_ERROR "${Z_VCPKG_FATAL_ERROR}")
endif()

cmake_policy(POP)
