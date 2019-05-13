# Mark variables as used so cmake doesn't complain about them
mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

# This is a backport of CMAKE_TRY_COMPILE_PLATFORM_VARIABLES to cmake 3.0
get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
if( _CMAKE_IN_TRY_COMPILE )
    include( "${CMAKE_CURRENT_SOURCE_DIR}/../vcpkg.config.cmake" OPTIONAL )
endif()

if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
endif()

if(VCPKG_TOOLCHAIN)
    return()
endif()

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
        if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^[Xx]86$")
            set(_VCPKG_TARGET_TRIPLET_ARCH x86)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^[Aa][Mm][Dd]64$")
            set(_VCPKG_TARGET_TRIPLET_ARCH x64)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^[Aa][Rr][Mm]$")
            set(_VCPKG_TARGET_TRIPLET_ARCH arm)
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "^[Aa][Rr][Mm]64$")
            set(_VCPKG_TARGET_TRIPLET_ARCH arm64)
        else()

        endif()
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
        elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
            set(_VCPKG_TARGET_TRIPLET_ARCH x64)
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
            message(FATAL_ERROR "Could not find .vcpkg-root")
        else()
            SET(_VCPKG_ROOT_DIR_CANDIDATE ${_VCPKG_ROOT_DIR_TEMP})
        endif()
    endwhile()
    set(_VCPKG_ROOT_DIR ${_VCPKG_ROOT_DIR_CANDIDATE} CACHE INTERNAL "Vcpkg root directory")
endif()
set(_VCPKG_INSTALLED_DIR ${_VCPKG_ROOT_DIR}/installed)

if(NOT EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" AND NOT _CMAKE_IN_TRY_COMPILE)
    message(WARNING "There are no libraries installed for the Vcpkg triplet ${VCPKG_TARGET_TRIPLET}.")
endif()

if(CMAKE_BUILD_TYPE MATCHES "^Debug$" OR NOT DEFINED CMAKE_BUILD_TYPE) 
#Debug build: Put Debug paths before Release paths.
    list(APPEND CMAKE_PREFIX_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug 
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
    )
    list(APPEND CMAKE_LIBRARY_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link 
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link
    )
    list(APPEND CMAKE_FIND_ROOT_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug 
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}
    )
else() 
#Release build: Put Release paths before Debug paths. 
#Debug Paths are required so that CMake generates correct info in autogenerated target files.
    list(APPEND CMAKE_PREFIX_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET} 
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug
    )
    list(APPEND CMAKE_LIBRARY_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link 
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib/manual-link
    )
    list(APPEND CMAKE_FIND_ROOT_PATH
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET} 
        ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug
    )
endif()

file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" _programfiles)
set(_PROGRAMFILESX86 "PROGRAMFILES(x86)")
file(TO_CMAKE_PATH "$ENV{${_PROGRAMFILESX86}}" _programfiles_x86)

#VCPKG will ignore default installation paths of OpenSSL on Windows. 
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

option(VCPKG_APPLOCAL_DEPS "Automatically copy dependencies into the output directory for executables." ON)

include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-add_executable.cmake)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-add_library.cmake)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-find_package.cmake)
include(${_VCPKG_TOOLCHAIN_DIR}/cmake/vcpkg-find_library.cmake)

set(VCPKG_TOOLCHAIN ON)
set(_UNUSED ${CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION})
set(_UNUSED ${CMAKE_EXPORT_NO_PACKAGE_REGISTRY})
set(_UNUSED ${CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY})
set(_UNUSED ${CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY})
set(_UNUSED ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP})

if(NOT _CMAKE_IN_TRY_COMPILE)
    file(TO_CMAKE_PATH "${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}" _chainload_file)
    file(TO_CMAKE_PATH "${_VCPKG_ROOT_DIR}" _root_dir)
    file(WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/vcpkg.config.cmake"
        "set(VCPKG_TARGET_TRIPLET \"${VCPKG_TARGET_TRIPLET}\" CACHE STRING \"\")\n"
        "set(VCPKG_APPLOCAL_DEPS \"${VCPKG_APPLOCAL_DEPS}\" CACHE STRING \"\")\n"
        "set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE \"${_chainload_file}\" CACHE STRING \"\")\n"
        "set(_VCPKG_ROOT_DIR \"${_root_dir}\" CACHE STRING \"\")\n"
        )
endif()
