# Mark variables as used so cmake doesn't complain about them
mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

# VCPKG toolchain options.
option(VCPKG_VERBOSE "Enables messages from the vcpkg toolchain for debugging purposes." OFF)
mark_as_advanced(VCPKG_VERBOSE)

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
        message(VERBOSE "[vcpkg]: CMAKE_MAP_IMPORTED_CONFIG_MINSIZEREL set to MinSizeRel;Release;")
    endif()
endif()
if(NOT DEFINED CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO)
    set(CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO "RelWithDebInfo;Release;")
    if(VCPKG_VERBOSE)
        message(VERBOSE "[vcpkg]: CMAKE_MAP_IMPORTED_CONFIG_RELWITHDEBINFO set to RelWithDebInfo;Release;")
    endif()
endif()


## vvvvv Automatic triplet selection
if(VCPKG_TARGET_TRIPLET)
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
                message(WARNING "[vcpkg]: Unable to determine target architecture. "
                                "Consider providing a value for the CMAKE_OSX_ARCHITECTURES cache variable. "
                                "Continuing without vcpkg.")
                set(VCPKG_TOOLCHAIN ON)
                return()
            else()
                if(arch_count GREATER 1)
                    message(WARNING "[vcpkg]: Detected more than one target architecture. Using the first one.")
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
                    message(WARNING "[vcpkg]: Unable to determine target architecture, continuing without vcpkg.")
                    set(VCPKG_TOOLCHAIN ON)
                    return()
                endif()
            endif()
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64" OR CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "AMD64")
            set(_VCPKG_TARGET_TRIPLET_ARCH x64)
        else()
            if( _CMAKE_IN_TRY_COMPILE )
                message(STATUS "[vcpkg]: Unable to determine target architecture, continuing without vcpkg.")
            else()
                message(WARNING "[vcpkg]: Unable to determine target architecture, continuing without vcpkg.")
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
set(_VCPKG_TOOLCHAIN_DIR "${CMAKE_CURRENT_LIST_DIR}")
## ^^^^^ Automatic triplet selection

# can we replace this with a find_file instead?
# vcpkg.json should probably always be placed in CMAKE_CURRENT_SOURCE_DIR OR CMAKE_SOURCE_DIR if not otherwise specified
# .vcpkg-root should probably always be loaceted in VCPKG_ROOT which is ../../ of CMAKE_CURRENT_LIST_DIR
function(_vcpkg_get_directory_name_of_file_above OUT DIRECTORY FILENAME) 
    set(_vcpkg_get_dir_candidate "${DIRECTORY}")
    while(IS_DIRECTORY "${_vcpkg_get_dir_candidate}" AND NOT DEFINED _vcpkg_get_dir_out)
        if(EXISTS "${_vcpkg_get_dir_candidate}/${FILENAME}")
            set(_vcpkg_get_dir_out "${_vcpkg_get_dir_candidate}")
        else()
            get_filename_component(_vcpkg_get_dir_candidate_tmp "${_vcpkg_get_dir_candidate}" DIRECTORY)
            if(_vcpkg_get_dir_candidate STREQUAL _vcpkg_get_dir_candidate_tmp) # we've reached the root dir
                set(_vcpkg_get_dir_out "${OUT}-NOTFOUND")
            elseif(_vcpkg_get_dir_candidate STREQUAL CMAKE_SOURCE_DIR OR _vcpkg_get_dir_candidate STREQUAL CMAKE_BINARY_DIR) # don't leak out source/buildtree!
                set(_vcpkg_get_dir_out "${OUT}-NOTFOUND")
            else()
                set(_vcpkg_get_dir_candidate "${_vcpkg_get_dir_candidate_tmp}")
            endif()
        endif()
    endwhile()
    set(${OUT} "${_vcpkg_get_dir_out}" PARENT_SCOPE)
endfunction()

_vcpkg_get_directory_name_of_file_above(_VCPKG_MANIFEST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg_manifest" "vcpkg.json") # Should this be CMAKE_SOURCE_DIR instead?
include(CMakeDependentOption)
CMAKE_DEPENDENT_OPTION (VCPKG_MANIFEST_MODE "Use vcpkg manifest mode by providing a vcpkg.json in the source directory." ON "EXISTS ${_VCPKG_MANIFEST_DIR}" OFF)

if(VCPKG_MANIFEST_MODE AND NOT _VCPKG_MANIFEST_DIR)
    message(FATAL_ERROR
        "vcpkg manifest mode was enabled, but we couldn't find a manifest file (vcpkg.json) "
        "in any directories above ${CMAKE_CURRENT_SOURCE_DIR}. Please add a manifest, or "
        "disable manifests by turning off VCPKG_MANIFEST_MODE.")
endif()

CMAKE_DEPENDENT_OPTION(VCPKG_MANIFEST_INSTALL
[[
Install the dependencies listed in your manifest:
    If this is off, you will have to manually install your dependencies.
    See https://github.com/microsoft/vcpkg/tree/master/docs/specifications/manifests.md for more info.
]] 
    ON "VCPKG_MANIFEST_MODE" OFF)

if(NOT _VCPKG_ROOT_DIR)
    _vcpkg_get_directory_name_of_file_above(_VCPKG_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}" ".vcpkg-root")
    message(FATAL_ERROR "Could not find .vcpkg-root")
endif()

if (NOT DEFINED VCPKG_TRIPLET_DIR)
    if(_VCPKG_MANIFEST_DIR)
        set(_VCPKG_INSTALLED_DIR_DEFAULT "${CMAKE_BINARY_DIR}/vcpkg_installed")
    else()
        set(_VCPKG_INSTALLED_DIR_DEFAULT "${_VCPKG_ROOT_DIR}/installed")
    endif()

    set(VCPKG_TRIPLET_DIR "${_VCPKG_INSTALLED_DIR_DEFAULT}/${VCPKG_TARGET_TRIPLET}"
            CACHE PATH
            "The directory which contains the installed libraries for the selected triplet")
endif()
set(_VCPKG_INSTALLED_DIR "${VCPKG_TRIPLET_DIR}/.."
        CACHE INTERNAL
        "The directory which contains the installed libraries for each triplet")

# CMAKE_EXECUTABLE_SUFFIX is not yet defined
if (CMAKE_HOST_WIN32)
    set(_VCPKG_EXECUTABLE "${_VCPKG_ROOT_DIR}/vcpkg.exe")
    set(_VCPKG_BOOTSTRAP_SCRIPT "${_VCPKG_ROOT_DIR}/bootstrap-vcpkg.bat")
else()
    set(_VCPKG_EXECUTABLE "${_VCPKG_ROOT_DIR}/vcpkg")
    set(_VCPKG_BOOTSTRAP_SCRIPT "${_VCPKG_ROOT_DIR}/bootstrap-vcpkg.sh")
endif()

if(VCPKG_MANIFEST_MODE AND VCPKG_MANIFEST_INSTALL AND NOT _CMAKE_IN_TRY_COMPILE)
    if(NOT EXISTS "${_VCPKG_EXECUTABLE}")
        message(STATUS "[vcpkg]: Bootstrapping vcpkg before install")

        execute_process(
            COMMAND "${_VCPKG_BOOTSTRAP_SCRIPT}"
            RESULT_VARIABLE _VCPKG_BOOTSTRAP_RESULT)

        if (NOT _VCPKG_BOOTSTRAP_RESULT EQUAL 0)
            message(FATAL_ERROR "[vcpkg]: Bootstrapping vcpkg before install - failed")
        endif()

        message(STATUS "[vcpkg]: Bootstrapping vcpkg before install - done")
    endif()

    message(STATUS "[vcpkg]: Running vcpkg install")

    set(VCPKG_INSTALL_CMD   "${_VCPKG_EXECUTABLE}" install
                            --triplet ${VCPKG_TARGET_TRIPLET}
                            --vcpkg-root "${_VCPKG_ROOT_DIR}"
                            "--x-manifest-root=\"${_VCPKG_MANIFEST_DIR}\""
                            "--x-install-root=\"${_VCPKG_INSTALLED_DIR}\""
                            --binarycaching)

    _vcpkg_get_directory_name_of_file_above(VCPKG_OVERLAY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg_manifest" "vcpkg.overlay")
    if(VCPKG_OVERLAY_DIR AND NOT VCPKG_PORT_OVERLAYS)
        list(APPEND VCPKG_PORT_OVERLAYS "${VCPKG_OVERLAY_DIR}/vcpkg.overlay")
    endif()
    if(VCPKG_PORT_OVERLAYS)
        foreach(_overlay IN LISTS VCPKG_PORT_OVERLAYS)
            list(APPEND VCPKG_INSTALL_CMD "--overlay-ports=\"${_overlay}\"")
        endforeach()
    endif()

    if(VCPKG_VERBOSE)
        message(VERBOSE "[vcpkg]: Executing vcpkg as: ${VCPKG_INSTALL_CMD}")
    endif()
    execute_process(COMMAND ${VCPKG_INSTALL_CMD} RESULT_VARIABLE _VCPKG_INSTALL_RESULT) 
    #Shouldn't the output be stored somewhere? especially if there is an error?

    if (NOT _VCPKG_INSTALL_RESULT EQUAL 0)
        message(FATAL_ERROR "[vcpkg]: Running vcpkg install - failed")
    endif()

    message(STATUS "[vcpkg]: Running vcpkg install - done")

    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
        "${_VCPKG_MANIFEST_DIR}/vcpkg.json"
        "${_VCPKG_INSTALLED_DIR}/vcpkg/status")
endif()

## Setup CMake
if(CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$" OR NOT DEFINED CMAKE_BUILD_TYPE) #Debug build: Put Debug paths before Release paths.
    list(APPEND CMAKE_PREFIX_PATH
        ${VCPKG_TRIPLET_DIR}/debug ${VCPKG_TRIPLET_DIR}
    )
    list(APPEND CMAKE_LIBRARY_PATH
        ${VCPKG_TRIPLET_DIR}/debug/lib/manual-link ${VCPKG_TRIPLET_DIR}/lib/manual-link
    )
    list(APPEND CMAKE_FIND_ROOT_PATH
        ${VCPKG_TRIPLET_DIR}/debug ${VCPKG_TRIPLET_DIR}
    )
else() #Release build: Put Release paths before Debug paths. Debug Paths are required so that CMake generates correct info in autogenerated target files.
    list(APPEND CMAKE_PREFIX_PATH
        ${VCPKG_TRIPLET_DIR} ${VCPKG_TRIPLET_DIR}/debug
    )
    list(APPEND CMAKE_LIBRARY_PATH
        ${VCPKG_TRIPLET_DIR}/lib/manual-link ${VCPKG_TRIPLET_DIR}/debug/lib/manual-link
    )
    list(APPEND CMAKE_FIND_ROOT_PATH
        ${VCPKG_TRIPLET_DIR} ${VCPKG_TRIPLET_DIR}/debug
    )
endif()

# If one CMAKE_FIND_ROOT_PATH_MODE_* variables is set to ONLY, to  make sure that ${VCPKG_TRIPLET_DIR}
# and ${VCPKG_TRIPLET_DIR}/debug are searched, it is not sufficient to just add them to CMAKE_FIND_ROOT_PATH,
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

list(APPEND CMAKE_PROGRAM_PATH ${VCPKG_TRIPLET_DIR}/tools)
file(GLOB _VCPKG_TOOLS_DIRS ${VCPKG_TRIPLET_DIR}/tools/*)
foreach(_VCPKG_TOOLS_DIR ${_VCPKG_TOOLS_DIRS})
    if(IS_DIRECTORY ${_VCPKG_TOOLS_DIR})
        list(APPEND CMAKE_PROGRAM_PATH ${_VCPKG_TOOLS_DIR})
    endif()
endforeach()

## Overrides of CMake functions
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
        set(Boost_COMPILER "-vc140")
        _find_package(${ARGV})
    elseif("${name}" STREQUAL "ICU" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/unicode/utf.h") # needs to be move to a wrapper if still necessary!
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
    elseif("${name}" STREQUAL "GSL" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/gsl") # needs to be move to a wrapper if still necessary!
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
    elseif("${name}" STREQUAL "CURL" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/curl") # needs to be move to a wrapper!
        _find_package(${ARGV})
        if(CURL_FOUND)
            if(EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/nghttp2.lib")
                list(APPEND CURL_LIBRARIES
                    "debug" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/nghttp2.lib"
                    "optimized" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/nghttp2.lib")
            endif()
        endif()
    elseif("${_vcpkg_lowercase_name}" STREQUAL "grpc" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/share/grpc") # needs to be move to a wrapper if still necessary!
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
