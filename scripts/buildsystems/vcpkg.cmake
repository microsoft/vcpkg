# Mark variables as used so cmake doesn't complain about them
mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

# VCPKG toolchain options.
option(VCPKG_VERBOSE "Enables messages from the VCPKG toolchain for debugging purposes." OFF)
mark_as_advanced(VCPKG_VERBOSE)

include(CMakeDependentOption)

function(_vcpkg_get_directory_name_of_file_above OUT DIRECTORY FILENAME)
    set(_vcpkg_get_dir_candidate ${DIRECTORY})
    while(IS_DIRECTORY ${_vcpkg_get_dir_candidate} AND NOT DEFINED _vcpkg_get_dir_out)
        if(EXISTS ${_vcpkg_get_dir_candidate}/${FILENAME})
            set(_vcpkg_get_dir_out ${_vcpkg_get_dir_candidate})
        else()
            get_filename_component(_vcpkg_get_dir_candidate_tmp ${_vcpkg_get_dir_candidate} DIRECTORY)
            if(_vcpkg_get_dir_candidate STREQUAL _vcpkg_get_dir_candidate_tmp) # we've reached the root
                set(_vcpkg_get_dir_out "${OUT}-NOTFOUND")
            else()
                set(_vcpkg_get_dir_candidate ${_vcpkg_get_dir_candidate_tmp})
            endif()
        endif()
    endwhile()

    set(${OUT} ${_vcpkg_get_dir_out} CACHE INTERNAL "_vcpkg_get_directory_name_of_file_above: ${OUT}")
endfunction()

if(NOT DEFINED VCPKG_MANIFEST_DIR)
    if(EXISTS "${CMAKE_SOURCE_DIR}/vcpkg.json")
        set(_VCPKG_MANIFEST_DIR "${CMAKE_SOURCE_DIR}")
    endif()
else()
    set(_VCPKG_MANIFEST_DIR ${VCPKG_MANIFEST_DIR})
endif()
if(NOT DEFINED VCPKG_MANIFEST_MODE)
    if(_VCPKG_MANIFEST_DIR)
        set(VCPKG_MANIFEST_MODE ON)
    else()
        set(VCPKG_MANIFEST_MODE OFF)
    endif()
elseif(VCPKG_MANIFEST_MODE AND NOT _VCPKG_MANIFEST_DIR)
    message(FATAL_ERROR
        "vcpkg manifest mode was enabled, but we couldn't find a manifest file (vcpkg.json) "
        "in any directories above ${CMAKE_CURRENT_SOURCE_DIR}. Please add a manifest, or "
        "disable manifests by turning off VCPKG_MANIFEST_MODE.")
endif()

if(NOT DEFINED _INTERNAL_CHECK_VCPKG_MANIFEST_MODE)
    set(_INTERNAL_CHECK_VCPKG_MANIFEST_MODE "${VCPKG_MANIFEST_MODE}"
        CACHE INTERNAL "Making sure VCPKG_MANIFEST_MODE doesn't change")
endif()

if(NOT VCPKG_MANIFEST_MODE STREQUAL _INTERNAL_CHECK_VCPKG_MANIFEST_MODE)
    message(FATAL_ERROR [[
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

# Determine whether the toolchain is loaded during a try-compile configuration
get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)

if (${CMAKE_VERSION} VERSION_LESS "3.6.0")
    set(_CMAKE_EMULATE_TRY_COMPILE_PLATFORM_VARIABLES ON)
else()
    set(_CMAKE_EMULATE_TRY_COMPILE_PLATFORM_VARIABLES OFF)
endif()

if(_CMAKE_IN_TRY_COMPILE AND _CMAKE_EMULATE_TRY_COMPILE_PLATFORM_VARIABLES)
    include("${CMAKE_CURRENT_SOURCE_DIR}/../vcpkg.config.cmake" OPTIONAL)
endif()

if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
endif()

if(VCPKG_TOOLCHAIN)
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
    set(VCPKG_TARGET_TRIPLET ${VCPKG_TARGET_TRIPLET} CACHE STRING "Vcpkg target triplet (ex. x86-windows)" FORCE)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Ww][Ii][Nn]32$")
    set(_VCPKG_TARGET_TRIPLET_ARCH x86)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Xx]64$")
    set(_VCPKG_TARGET_TRIPLET_ARCH x64)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]$")
    set(_VCPKG_TARGET_TRIPLET_ARCH arm)
elseif(CMAKE_GENERATOR_PLATFORM MATCHES "^[Aa][Rr][Mm]64$")
    set(_VCPKG_TARGET_TRIPLET_ARCH arm64)
else()
    if(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 Win64$")
        set(_VCPKG_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015 ARM$")
        set(_VCPKG_TARGET_TRIPLET_ARCH arm)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 14 2015$")
        set(_VCPKG_TARGET_TRIPLET_ARCH x86)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 Win64$")
        set(_VCPKG_TARGET_TRIPLET_ARCH x64)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017 ARM$")
        set(_VCPKG_TARGET_TRIPLET_ARCH arm)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 15 2017$")
        set(_VCPKG_TARGET_TRIPLET_ARCH x86)
    elseif(CMAKE_GENERATOR MATCHES "^Visual Studio 16 2019$")
        set(_VCPKG_TARGET_TRIPLET_ARCH x64)
    else()
        find_program(_VCPKG_CL cl)
        if(_VCPKG_CL MATCHES "amd64/cl.exe$" OR _VCPKG_CL MATCHES "x64/cl.exe$")
            set(_VCPKG_TARGET_TRIPLET_ARCH x64)
        elseif(_VCPKG_CL MATCHES "arm/cl.exe$")
            set(_VCPKG_TARGET_TRIPLET_ARCH arm)
        elseif(_VCPKG_CL MATCHES "arm64/cl.exe$")
            set(_VCPKG_TARGET_TRIPLET_ARCH arm64)
        elseif(_VCPKG_CL MATCHES "bin/cl.exe$" OR _VCPKG_CL MATCHES "x86/cl.exe$")
            set(_VCPKG_TARGET_TRIPLET_ARCH x86)
        elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin" AND DEFINED CMAKE_SYSTEM_NAME AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            list(LENGTH CMAKE_OSX_ARCHITECTURES arch_count)
            if(arch_count EQUAL 0)
                message(WARNING "Unable to determine target architecture. "
                                "Consider providing a value for the CMAKE_OSX_ARCHITECTURES cache variable. "
                                "Continuing without vcpkg.")
                set(VCPKG_TOOLCHAIN ON)
                return()
            else()
                if(arch_count GREATER 1)
                    message(WARNING "Detected more than one target architecture. Using the first one.")
                endif()
                list(GET CMAKE_OSX_ARCHITECTURES 0 target_arch)
                if(target_arch STREQUAL arm64)
                    set(_VCPKG_TARGET_TRIPLET_ARCH arm64)
                elseif(target_arch STREQUAL arm64s)
                    set(_VCPKG_TARGET_TRIPLET_ARCH arm64s)
                elseif(target_arch STREQUAL armv7s)
                    set(_VCPKG_TARGET_TRIPLET_ARCH armv7s)
                elseif(target_arch STREQUAL armv7)
                    set(_VCPKG_TARGET_TRIPLET_ARCH arm)
                elseif(target_arch STREQUAL x86_64)
                    set(_VCPKG_TARGET_TRIPLET_ARCH x64)
                elseif(target_arch STREQUAL i386)
                    set(_VCPKG_TARGET_TRIPLET_ARCH x86)
                else()
                    message(WARNING "Unable to determine target architecture, continuing without vcpkg.")
                    set(VCPKG_TOOLCHAIN ON)
                    return()
                endif()
            endif()
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64" OR CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "AMD64")
            set(_VCPKG_TARGET_TRIPLET_ARCH x64)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "s390x")
            set(_VCPKG_TARGET_TRIPLET_ARCH s390x)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "armv7l")
            set(_VCPKG_TARGET_TRIPLET_ARCH arm)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "aarch64")
            set(_VCPKG_TARGET_TRIPLET_ARCH arm64)
        else()
            if( _CMAKE_IN_TRY_COMPILE )
                message(STATUS "Unable to determine target architecture, continuing without vcpkg.")
            else()
                message(WARNING "Unable to determine target architecture, continuing without vcpkg.")
            endif()
            set(VCPKG_TOOLCHAIN ON)
            return()
        endif()
    endif()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR CMAKE_SYSTEM_NAME STREQUAL "WindowsPhone")
    set(_VCPKG_TARGET_TRIPLET_PLAT uwp)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"))
    set(_VCPKG_TARGET_TRIPLET_PLAT linux)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin"))
    set(_VCPKG_TARGET_TRIPLET_PLAT osx)
elseif(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(_VCPKG_TARGET_TRIPLET_PLAT ios)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
    set(_VCPKG_TARGET_TRIPLET_PLAT windows)
elseif(CMAKE_SYSTEM_NAME STREQUAL "FreeBSD" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD"))
    set(_VCPKG_TARGET_TRIPLET_PLAT freebsd)
endif()

set(VCPKG_TARGET_TRIPLET ${_VCPKG_TARGET_TRIPLET_ARCH}-${_VCPKG_TARGET_TRIPLET_PLAT} CACHE STRING "Vcpkg target triplet (ex. x86-windows)")
set(_VCPKG_TOOLCHAIN_DIR ${CMAKE_CURRENT_LIST_DIR})

if(NOT DEFINED _VCPKG_ROOT_DIR)
    # Detect .vcpkg-root to figure VCPKG_ROOT_DIR
    set(_VCPKG_ROOT_DIR_CANDIDATE ${CMAKE_CURRENT_LIST_DIR})
    while(IS_DIRECTORY ${_VCPKG_ROOT_DIR_CANDIDATE} AND NOT EXISTS "${_VCPKG_ROOT_DIR_CANDIDATE}/.vcpkg-root")
        get_filename_component(_VCPKG_ROOT_DIR_TEMP ${_VCPKG_ROOT_DIR_CANDIDATE} DIRECTORY)
        if (_VCPKG_ROOT_DIR_TEMP STREQUAL _VCPKG_ROOT_DIR_CANDIDATE) # If unchanged, we have reached the root of the drive
        else()
            SET(_VCPKG_ROOT_DIR_CANDIDATE ${_VCPKG_ROOT_DIR_TEMP})
        endif()
    endwhile()
    set(_VCPKG_ROOT_DIR ${_VCPKG_ROOT_DIR_CANDIDATE} CACHE INTERNAL "Vcpkg root directory")
endif()

_vcpkg_get_directory_name_of_file_above(_VCPKG_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR} ".vcpkg-root")
if(NOT _VCPKG_ROOT_DIR)
    message(FATAL_ERROR "Could not find .vcpkg-root")
endif()

if (NOT DEFINED _VCPKG_INSTALLED_DIR)
    if(_VCPKG_MANIFEST_DIR)
        set(_VCPKG_INSTALLED_DIR ${CMAKE_BINARY_DIR}/vcpkg_installed)
    else()
        set(_VCPKG_INSTALLED_DIR ${_VCPKG_ROOT_DIR}/installed)
    endif()

    set(_VCPKG_INSTALLED_DIR ${_VCPKG_INSTALLED_DIR}
        CACHE PATH
        "The directory which contains the installed libraries for each triplet")
endif()

if(CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$" OR NOT DEFINED CMAKE_BUILD_TYPE) #Debug build: Put Debug paths before Release paths.
    list(APPEND CMAKE_PREFIX_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
    )
    list(APPEND CMAKE_LIBRARY_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link
    )
    list(APPEND CMAKE_FIND_ROOT_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
    )
else() #Release build: Put Release paths before Debug paths. Debug Paths are required so that CMake generates correct info in autogenerated target files.
    list(APPEND CMAKE_PREFIX_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET} ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug
    )
    list(APPEND CMAKE_LIBRARY_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link
    )
    list(APPEND CMAKE_FIND_ROOT_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET} ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug
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

set(VCPKG_CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH})

file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" _programfiles)
set(_PROGRAMFILESX86 "PROGRAMFILES(x86)")
file(TO_CMAKE_PATH "$ENV{${_PROGRAMFILESX86}}" _programfiles_x86)
set(CMAKE_SYSTEM_IGNORE_PATH
    "${_programfiles}/OpenSSL"
    "${_programfiles}/OpenSSL-Win32"
    "${_programfiles}/OpenSSL-Win64"
    "${_programfiles}/OpenSSL-Win32/lib/VC"
    "${_programfiles}/OpenSSL-Win64/lib/VC"
    "${_programfiles}/OpenSSL-Win32/lib/VC/static"
    "${_programfiles}/OpenSSL-Win64/lib/VC/static"
    "${_programfiles_x86}/OpenSSL"
    "${_programfiles_x86}/OpenSSL-Win32"
    "${_programfiles_x86}/OpenSSL-Win64"
    "${_programfiles_x86}/OpenSSL-Win32/lib/VC"
    "${_programfiles_x86}/OpenSSL-Win64/lib/VC"
    "${_programfiles_x86}/OpenSSL-Win32/lib/VC/static"
    "${_programfiles_x86}/OpenSSL-Win64/lib/VC/static"
    "C:/OpenSSL/"
    "C:/OpenSSL-Win32/"
    "C:/OpenSSL-Win64/"
    "C:/OpenSSL-Win32/lib/VC"
    "C:/OpenSSL-Win64/lib/VC"
    "C:/OpenSSL-Win32/lib/VC/static"
    "C:/OpenSSL-Win64/lib/VC/static"
)

list(APPEND CMAKE_PROGRAM_PATH ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools)
file(GLOB _VCPKG_TOOLS_DIRS ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/*)
foreach(_VCPKG_TOOLS_DIR ${_VCPKG_TOOLS_DIRS})
    if(IS_DIRECTORY ${_VCPKG_TOOLS_DIR})
        list(APPEND CMAKE_PROGRAM_PATH ${_VCPKG_TOOLS_DIR})
    endif()
endforeach()


# CMAKE_EXECUTABLE_SUFFIX is not yet defined
if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(_VCPKG_EXECUTABLE "${_VCPKG_ROOT_DIR}/vcpkg.exe")
    set(_VCPKG_BOOTSTRAP_SCRIPT "${_VCPKG_ROOT_DIR}/bootstrap-vcpkg.bat")
else()
    set(_VCPKG_EXECUTABLE "${_VCPKG_ROOT_DIR}/vcpkg")
    set(_VCPKG_BOOTSTRAP_SCRIPT "${_VCPKG_ROOT_DIR}/bootstrap-vcpkg.sh")
endif()

if(VCPKG_MANIFEST_MODE AND VCPKG_MANIFEST_INSTALL AND NOT _CMAKE_IN_TRY_COMPILE)
    set(VCPKG_BOOTSTRAP_OPTIONS "${VCPKG_BOOTSTRAP_OPTIONS}" CACHE STRING "Additional options to bootstrap vcpkg" FORCE)
    mark_as_advanced(VCPKG_BOOTSTRAP_OPTIONS)

    if(NOT EXISTS "${_VCPKG_EXECUTABLE}")
        message(STATUS "Bootstrapping vcpkg before install")

        execute_process(
            COMMAND "${_VCPKG_BOOTSTRAP_SCRIPT}" ${VCPKG_BOOTSTRAP_OPTIONS}
            RESULT_VARIABLE _VCPKG_BOOTSTRAP_RESULT)

        if (NOT _VCPKG_BOOTSTRAP_RESULT EQUAL 0)
            message(FATAL_ERROR "Bootstrapping vcpkg before install - failed")
        endif()

        message(STATUS "Bootstrapping vcpkg before install - done")
    endif()

    set(VCPKG_OVERLAY_PORTS "${VCPKG_OVERLAY_PORTS}" CACHE STRING "Overlay ports to use for vcpkg install in manifest mode" FORCE)
    mark_as_advanced(VCPKG_OVERLAY_PORTS)
    set(VCPKG_OVERLAY_TRIPLETS "${VCPKG_OVERLAY_TRIPLETS}" CACHE STRING "Overlay triplets to use for vcpkg install in manifest mode" FORCE)
    mark_as_advanced(VCPKG_OVERLAY_TRIPLETS)
    set(VCPKG_INSTALL_OPTIONS "${VCPKG_INSTALL_OPTIONS}" CACHE STRING "Additional install options to pass to vcpkg" FORCE)
    mark_as_advanced(VCPKG_INSTALL_OPTIONS)

    message(STATUS "Running vcpkg install")

    set(_VCPKG_ADDITIONAL_MANIFEST_PARAMS)
    if(VCPKG_OVERLAY_PORTS)
        foreach(_overlay_port IN LISTS VCPKG_OVERLAY_PORTS)
            list(APPEND _VCPKG_ADDITIONAL_MANIFEST_PARAMS "--overlay-ports=${_overlay_port}")
        endforeach()
    endif()
    if(VCPKG_OVERLAY_TRIPLETS)
        foreach(_overlay_triplet IN LISTS VCPKG_OVERLAY_TRIPLETS)
            list(APPEND _VCPKG_ADDITIONAL_MANIFEST_PARAMS "--overlay-triplets=${_overlay_triplet}")
        endforeach()
    endif()

    foreach(feature ${VCPKG_MANIFEST_FEATURES})
        list(APPEND _VCPKG_ADDITIONAL_MANIFEST_PARAMS "--x-feature=${feature}")
    endforeach()

    if(VCPKG_MANIFEST_NO_DEFAULT_FEATURES)
        list(APPEND _VCPKG_ADDITIONAL_MANIFEST_PARAMS "--x-no-default-features")
    endif()

    execute_process(
        COMMAND "${_VCPKG_EXECUTABLE}" install
            --triplet "${VCPKG_TARGET_TRIPLET}"
            --vcpkg-root "${_VCPKG_ROOT_DIR}"
            "--x-manifest-root=${_VCPKG_MANIFEST_DIR}"
            "--x-install-root=${_VCPKG_INSTALLED_DIR}"
            ${_VCPKG_ADDITIONAL_MANIFEST_PARAMS}
            ${VCPKG_INSTALL_OPTIONS}
        OUTPUT_FILE "${CMAKE_BINARY_DIR}/vcpkg-manifest-install-out.log"
        ERROR_FILE "${CMAKE_BINARY_DIR}/vcpkg-manifest-install-err.log"
        RESULT_VARIABLE _VCPKG_INSTALL_RESULT
    )

    if (NOT _VCPKG_INSTALL_RESULT EQUAL 0)
        message(FATAL_ERROR "Running vcpkg install - failed")
    endif()

    message(STATUS "Running vcpkg install - done")

    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
        "${_VCPKG_MANIFEST_DIR}/vcpkg.json"
        "${_VCPKG_INSTALLED_DIR}/vcpkg/status")
endif()

option(VCPKG_APPLOCAL_DEPS "Automatically copy dependencies into the output directory for executables." ON)
function(add_executable name)
    _add_executable(${ARGV})
    list(FIND ARGV "IMPORTED" IMPORTED_IDX)
    list(FIND ARGV "ALIAS" ALIAS_IDX)
    list(FIND ARGV "MACOSX_BUNDLE" MACOSX_BUNDLE_IDX)
    if(IMPORTED_IDX EQUAL -1 AND ALIAS_IDX EQUAL -1)
        if(VCPKG_APPLOCAL_DEPS)
            if(_VCPKG_TARGET_TRIPLET_PLAT MATCHES "windows|uwp")
                add_custom_command(TARGET ${name} POST_BUILD
                    COMMAND powershell -noprofile -executionpolicy Bypass -file ${_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1
                        -targetBinary $<TARGET_FILE:${name}>
                        -installedDir "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin"
                        -OutVariable out
                )
            elseif(_VCPKG_TARGET_TRIPLET_PLAT MATCHES "osx")
                if (NOT MACOSX_BUNDLE_IDX EQUAL -1)
                    add_custom_command(TARGET ${name} POST_BUILD
                    COMMAND python ${_VCPKG_TOOLCHAIN_DIR}/osx/applocal.py
                        $<TARGET_FILE:${name}>
                        "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>"
                    )
                endif()
            endif()
        endif()
        set_target_properties(${name} PROPERTIES VS_USER_PROPS do_not_import_user.props)
        set_target_properties(${name} PROPERTIES VS_GLOBAL_VcpkgEnabled false)
    endif()
endfunction()

function(add_library name)
    _add_library(${ARGV})
    list(FIND ARGV "IMPORTED" IMPORTED_IDX)
    list(FIND ARGV "INTERFACE" INTERFACE_IDX)
    list(FIND ARGV "ALIAS" ALIAS_IDX)
    if(IMPORTED_IDX EQUAL -1 AND INTERFACE_IDX EQUAL -1 AND ALIAS_IDX EQUAL -1)
        get_target_property(IS_LIBRARY_SHARED ${name} TYPE)
        if(VCPKG_APPLOCAL_DEPS AND _VCPKG_TARGET_TRIPLET_PLAT MATCHES "windows|uwp" AND (IS_LIBRARY_SHARED STREQUAL "SHARED_LIBRARY" OR IS_LIBRARY_SHARED STREQUAL "MODULE_LIBRARY"))
            add_custom_command(TARGET ${name} POST_BUILD
                COMMAND powershell -noprofile -executionpolicy Bypass -file ${_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1
                    -targetBinary $<TARGET_FILE:${name}>
                    -installedDir "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin"
                    -OutVariable out
            )
        endif()
        set_target_properties(${name} PROPERTIES VS_USER_PROPS do_not_import_user.props)
        set_target_properties(${name} PROPERTIES VS_GLOBAL_VcpkgEnabled false)
    endif()
endfunction()

# This is an experimental function to enable applocal install of dependencies as part of the `make install` process
# Arguments:
#   TARGETS - a list of installed targets to have dependencies copied for
#   DESTINATION - the runtime directory for those targets (usually `bin`)
function(x_vcpkg_install_local_dependencies)
    if(_VCPKG_TARGET_TRIPLET_PLAT MATCHES "windows|uwp")
        # Parse command line
        cmake_parse_arguments(__VCPKG_APPINSTALL "" "DESTINATION" "TARGETS" ${ARGN})

        foreach(TARGET ${__VCPKG_APPINSTALL_TARGETS})
            _install(CODE "message(\"-- Installing app dependencies for ${TARGET}...\")
                execute_process(COMMAND 
                    powershell -noprofile -executionpolicy Bypass -file \"${_VCPKG_TOOLCHAIN_DIR}/msbuild/applocal.ps1\"
                    -targetBinary \"${__VCPKG_APPINSTALL_DESTINATION}/$<TARGET_FILE_NAME:${TARGET}>\"
                    -installedDir \"${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<$<CONFIG:Debug>:/debug>/bin\"
                    -OutVariable out)")
        endforeach()
    endif()
endfunction()

if(NOT DEFINED VCPKG_OVERRIDE_FIND_PACKAGE_NAME)
    set(VCPKG_OVERRIDE_FIND_PACKAGE_NAME find_package)
endif()
macro(${VCPKG_OVERRIDE_FIND_PACKAGE_NAME} name)
    # Workaround to set the ROOT_PATH until upstream CMake stops overriding
    # the ROOT_PATH at apple OS initialization phase.
    # See https://gitlab.kitware.com/cmake/cmake/merge_requests/3273
    if(CMAKE_SYSTEM_NAME STREQUAL iOS)
        set(BACKUP_CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH})
        list(APPEND CMAKE_FIND_ROOT_PATH ${VCPKG_CMAKE_FIND_ROOT_PATH})
    endif()
    string(TOLOWER "${name}" _vcpkg_lowercase_name)

    if(EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/${_vcpkg_lowercase_name}/vcpkg-cmake-wrapper.cmake")
        set(ARGS "${ARGV}")
        include(${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/${_vcpkg_lowercase_name}/vcpkg-cmake-wrapper.cmake)
    elseif("${name}" STREQUAL "Boost" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/boost")
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
        _find_package(${ARGV})
    elseif("${name}" STREQUAL "ICU" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/unicode/utf.h")
        function(_vcpkg_find_in_list)
            list(FIND ARGV "COMPONENTS" COMPONENTS_IDX)
            set(COMPONENTS_IDX ${COMPONENTS_IDX} PARENT_SCOPE)
        endfunction()
        _vcpkg_find_in_list(${ARGV})
        if(NOT COMPONENTS_IDX EQUAL -1)
            _find_package(${ARGV} COMPONENTS data)
        else()
            _find_package(${ARGV})
        endif()
    elseif("${name}" STREQUAL "GSL" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/gsl")
        _find_package(${ARGV})
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
    elseif("${name}" STREQUAL "CURL" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/curl")
        _find_package(${ARGV})
        if(CURL_FOUND)
            if(EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/nghttp2.lib")
                list(APPEND CURL_LIBRARIES
                    "debug" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/nghttp2.lib"
                    "optimized" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/nghttp2.lib")
            endif()
        endif()
    elseif("${_vcpkg_lowercase_name}" STREQUAL "grpc" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/grpc")
        _find_package(gRPC ${ARGN})
    else()
        _find_package(${ARGV})
    endif()
    if(CMAKE_SYSTEM_NAME STREQUAL iOS)
        set(CMAKE_FIND_ROOT_PATH "${BACKUP_CMAKE_FIND_ROOT_PATH}")
    endif()
endmacro()

set(VCPKG_TOOLCHAIN ON)
set(_UNUSED ${CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION})
set(_UNUSED ${CMAKE_EXPORT_NO_PACKAGE_REGISTRY})
set(_UNUSED ${CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY})
set(_UNUSED ${CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY})
set(_UNUSED ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP})

# Propogate these values to try-compile configurations so the triplet and toolchain load
if(NOT _CMAKE_IN_TRY_COMPILE)
    if(_CMAKE_EMULATE_TRY_COMPILE_PLATFORM_VARIABLES)
        file(TO_CMAKE_PATH "${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}" _chainload_file)
        file(TO_CMAKE_PATH "${_VCPKG_ROOT_DIR}" _root_dir)
        file(WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/vcpkg.config.cmake"
            "set(VCPKG_TARGET_TRIPLET \"${VCPKG_TARGET_TRIPLET}\" CACHE STRING \"\")\n"
            "set(VCPKG_TARGET_ARCHITECTURE \"${VCPKG_TARGET_ARCHITECTURE}\" CACHE STRING \"\")\n"
            "set(VCPKG_APPLOCAL_DEPS \"${VCPKG_APPLOCAL_DEPS}\" CACHE STRING \"\")\n"
            "set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE \"${_chainload_file}\" CACHE STRING \"\")\n"
            "set(_VCPKG_ROOT_DIR \"${_root_dir}\" CACHE STRING \"\")\n"
        )
    else()
        list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
            VCPKG_TARGET_TRIPLET
            VCPKG_TARGET_ARCHITECTURE
            VCPKG_APPLOCAL_DEPS
            VCPKG_CHAINLOAD_TOOLCHAIN_FILE
            _VCPKG_ROOT_DIR
        )
    endif()
endif()
