if(NOT _VCPKG_MINGW_TOOLCHAIN)
set(_VCPKG_MINGW_TOOLCHAIN 1)

#[===[.md:
# z_vcpkg_message
Log messages to cmake or a file

```cmake
z_vcpkg_message(<FATAL_ERROR|...> <message>...)
```

This macro is used instead of cmake `message(...)` because we want
to pass the messages to the calling process during `detect_compiler`.

To activate logging to a file, set `_VCPKG_TOOLCHAIN_MESSAGES_FILE` to the
desired file path. In the log file, fatal errors are preceded by a line
containing "Fatal error:".
#]===]
set(Z_VCPKG_TOOLCHAIN_MESSAGES )
macro(z_vcpkg_message SEVERITY MESSAGE)
    if(NOT _VCPKG_TOOLCHAIN_MESSAGES_FILE)
        message(${SEVERITY} "${MESSAGE}")
    elseif(NOT "${SEVERITY}" MATCHES "ERROR")
        message(${SEVERITY} "${MESSAGE}")
        string(APPEND Z_VCPKG_TOOLCHAIN_MESSAGES "${MESSAGE}\n")
    else()
        message(WARNING "${MESSAGE}")
        string(APPEND Z_VCPKG_TOOLCHAIN_MESSAGES "Fatal error:\n${MESSAGE}\n")
        file(WRITE "${_VCPKG_TOOLCHAIN_MESSAGES_FILE}" "${Z_VCPKG_TOOLCHAIN_MESSAGES}")
        return()
    endif()
endmacro()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
endif()

# Need to override MinGW from VCPKG_CMAKE_SYSTEM_NAME
set(CMAKE_SYSTEM_NAME Windows CACHE STRING "" FORCE)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
   set(CMAKE_SYSTEM_PROCESSOR i686 CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
   set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
   set(CMAKE_SYSTEM_PROCESSOR armv7 CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
   set(CMAKE_SYSTEM_PROCESSOR aarch64 CACHE STRING "")
endif()

foreach(lang C CXX)
  set(CMAKE_${lang}_COMPILER_TARGET "${CMAKE_SYSTEM_PROCESSOR}-windows-gnu" CACHE STRING "")
endforeach()

set(_MINGW_TARGET_TRIPLET ${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32)

macro(_mingw_find_program variable prog_name)
find_program(${variable} "${_MINGW_TARGET_TRIPLET}-${prog_name}")
if(NOT ${variable})
    find_program(${variable} "${prog_name}")
    if(NOT ${prog_name}_UNPREFIXED)
        set(${prog_name}_UNPREFIXED TRUE CACHE INTERNAL "")
        z_vcpkg_message(WARNING
            "${_MINGW_TARGET_TRIPLET}-${prog_name} not found, falling back to ${prog_name}.")
    endif()
endif()
endmacro()

_mingw_find_program(CMAKE_C_COMPILER "gcc")
_mingw_find_program(CMAKE_CXX_COMPILER "g++")
_mingw_find_program(CMAKE_RC_COMPILER "windres")
if(NOT CMAKE_C_COMPILER)
    z_vcpkg_message(FATAL_ERROR "Cannot find a compiler! Please check your PATH variable.")
endif()

macro(_mingw_check_target prog)
get_filename_component(prog_name ${prog} NAME_WE)
execute_process(COMMAND ${prog} -dumpmachine OUTPUT_VARIABLE _DUMPMACHINE)
string(REPLACE "-" ";" _DUMPMACHINE ${_DUMPMACHINE})
list(GET _DUMPMACHINE 0 _COMPILER_CPU)
list(GET _DUMPMACHINE 1 _COMPILER_VENDOR)
list(GET _DUMPMACHINE 2 _COMPILER_OS)
if(NOT _COMPILER_OS MATCHES "(mingw32)|(windows)")
    z_vcpkg_message(FATAL_ERROR "\
Incorrect compiler OS. Expected mingw32 or windows, got ${_COMPILER_OS}
Compiler path: ${prog}")
endif()
if(_COMPILER_VENDOR STREQUAL "pc") # Old MinGW toolchain
    if(NOT ${prog_name}_OLD_MINGW)
        set(${prog_name}_OLD_MINGW TRUE CACHE INTERNAL "")
        z_vcpkg_message(WARNING "\
Old MinGW toolchain detected. This is not guaranteed to work with vcpkg. Proceed with caution
Compiler path: ${prog}")
    endif()
endif()
if(NOT _COMPILER_CPU STREQUAL CMAKE_SYSTEM_PROCESSOR)
    z_vcpkg_message(FATAL_ERROR "\
Incorrect compiler CPU. Expected ${CMAKE_SYSTEM_PROCESSOR}, got ${_COMPILER_CPU}
Compiler path: ${prog}")
endif()
endmacro()

_mingw_check_target(${CMAKE_C_COMPILER})
_mingw_check_target(${CMAKE_CXX_COMPILER})

get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
if(NOT _CMAKE_IN_TRY_COMPILE)
    string(APPEND CMAKE_C_FLAGS_INIT " ${VCPKG_C_FLAGS} ")
    string(APPEND CMAKE_CXX_FLAGS_INIT " ${VCPKG_CXX_FLAGS} ")
    string(APPEND CMAKE_C_FLAGS_DEBUG_INIT " ${VCPKG_C_FLAGS_DEBUG} ")
    string(APPEND CMAKE_CXX_FLAGS_DEBUG_INIT " ${VCPKG_CXX_FLAGS_DEBUG} ")
    string(APPEND CMAKE_C_FLAGS_RELEASE_INIT " ${VCPKG_C_FLAGS_RELEASE} ")
    string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT " ${VCPKG_CXX_FLAGS_RELEASE} ")

    string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT "-static ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT "-static ")
    endif()
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
endif()
endif()
