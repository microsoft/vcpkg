if(NOT _VCPKG_MINGW_TOOLCHAIN)
    set(_VCPKG_MINGW_TOOLCHAIN 1)

    if(POLICY CMP0056)
        cmake_policy(SET CMP0056 NEW)
    endif()
    if(POLICY CMP0066)
        cmake_policy(SET CMP0066 NEW)
    endif()
    if(POLICY CMP0067)
        cmake_policy(SET CMP0067 NEW)
    endif()
    if(POLICY CMP0137)
        cmake_policy(SET CMP0137 NEW)
    endif()
    list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
        VCPKG_CRT_LINKAGE VCPKG_TARGET_ARCHITECTURE
        VCPKG_C_FLAGS VCPKG_CXX_FLAGS
        VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
        VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
        VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
        _VCPKG_MINGW_PREVIOUS_PROJECT_INCLUDE
    )

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
      set(CMAKE_${lang}_COMPILER_TARGET "${CMAKE_SYSTEM_PROCESSOR}-w64-windows-gnu" CACHE STRING "")
    endforeach()

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(_VCPKG_MINGW_TARGET_REGEX "^(i[3-6]86|x86)-.*-mingw32$")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(_VCPKG_MINGW_TARGET_REGEX "^(x86_64|amd64)-.*-mingw32$")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(_VCPKG_MINGW_TARGET_REGEX "^(arm|armv[0-9]+)-.*-mingw32$")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(_VCPKG_MINGW_TARGET_REGEX "^(aarch64|arm64)-.*-mingw32$")
    else()
        message(FATAL_ERROR "Unsupported MinGW target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    function(_vcpkg_validate_mingw_compiler compiler language target_regex)
        execute_process(
            COMMAND "${compiler}" -dumpmachine
            OUTPUT_VARIABLE _compiler_target
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE _compiler_error
            RESULT_VARIABLE _compiler_result
        )
        if(NOT _compiler_result EQUAL 0 OR NOT _compiler_target MATCHES "${target_regex}")
            if(language STREQUAL "C")
                unset(CMAKE_C_COMPILER CACHE)
                unset(CMAKE_C_COMPILER PARENT_SCOPE)
                unset(_VCPKG_MINGW_C_FALLBACK_COMPILER CACHE)
                unset(_VCPKG_MINGW_C_FALLBACK_COMPILER PARENT_SCOPE)
            elseif(language STREQUAL "C++")
                unset(CMAKE_CXX_COMPILER CACHE)
                unset(CMAKE_CXX_COMPILER PARENT_SCOPE)
                unset(_VCPKG_MINGW_CXX_FALLBACK_COMPILER CACHE)
                unset(_VCPKG_MINGW_CXX_FALLBACK_COMPILER PARENT_SCOPE)
            endif()

            message(FATAL_ERROR
                "The fallback MinGW ${language} compiler '${compiler}' is incompatible with "
                "the requested ${VCPKG_TARGET_ARCHITECTURE} target. "
                "Its -dumpmachine output was '${_compiler_target}'. "
                "Compiler error output: '${_compiler_error}'. "
                "Select a matching MinGW compiler or install the target-prefixed compiler."
            )
        endif()
    endfunction()

    find_program(CMAKE_C_COMPILER NAMES "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-gcc")
    if(NOT CMAKE_C_COMPILER)
        find_program(CMAKE_C_COMPILER NAMES gcc)
    endif()
    if(CMAKE_C_COMPILER)
        get_filename_component(_VCPKG_MINGW_C_COMPILER_NAME "${CMAKE_C_COMPILER}" NAME)
        string(TOLOWER "${_VCPKG_MINGW_C_COMPILER_NAME}" _VCPKG_MINGW_C_COMPILER_NAME)
        string(REGEX REPLACE "\\.exe$" "" _VCPKG_MINGW_C_COMPILER_NAME "${_VCPKG_MINGW_C_COMPILER_NAME}")
        if(_VCPKG_MINGW_C_COMPILER_NAME MATCHES "(^|-)gcc$"
            AND NOT _VCPKG_MINGW_C_COMPILER_NAME STREQUAL "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-gcc")
            set(_VCPKG_MINGW_C_FALLBACK_COMPILER "${CMAKE_C_COMPILER}" CACHE INTERNAL "")
        else()
            unset(_VCPKG_MINGW_C_FALLBACK_COMPILER CACHE)
        endif()
    endif()

    find_program(CMAKE_CXX_COMPILER NAMES "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-g++")
    if(NOT CMAKE_CXX_COMPILER)
        find_program(CMAKE_CXX_COMPILER NAMES g++)
    endif()
    if(CMAKE_CXX_COMPILER)
        get_filename_component(_VCPKG_MINGW_CXX_COMPILER_NAME "${CMAKE_CXX_COMPILER}" NAME)
        string(TOLOWER "${_VCPKG_MINGW_CXX_COMPILER_NAME}" _VCPKG_MINGW_CXX_COMPILER_NAME)
        string(REGEX REPLACE "\\.exe$" "" _VCPKG_MINGW_CXX_COMPILER_NAME "${_VCPKG_MINGW_CXX_COMPILER_NAME}")
        if(_VCPKG_MINGW_CXX_COMPILER_NAME MATCHES "(^|-)g\\+\\+$"
            AND NOT _VCPKG_MINGW_CXX_COMPILER_NAME STREQUAL "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-g++")
            set(_VCPKG_MINGW_CXX_FALLBACK_COMPILER "${CMAKE_CXX_COMPILER}" CACHE INTERNAL "")
        else()
            unset(_VCPKG_MINGW_CXX_FALLBACK_COMPILER CACHE)
        endif()
    endif()

    # CMAKE_PROJECT_INCLUDE runs after project() enables its requested languages.
    # Chain any existing hook rather than replacing user-provided project setup.
    set(_VCPKG_MINGW_VALIDATION_HOOK "${CMAKE_CURRENT_LIST_DIR}/mingw-validate.cmake")
    if(NOT CMAKE_PROJECT_INCLUDE STREQUAL _VCPKG_MINGW_VALIDATION_HOOK)
        set(_VCPKG_MINGW_PREVIOUS_PROJECT_INCLUDE "${CMAKE_PROJECT_INCLUDE}")
    endif()
    set(CMAKE_PROJECT_INCLUDE "${_VCPKG_MINGW_VALIDATION_HOOK}")

    find_program(CMAKE_RC_COMPILER NAMES "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-windres" windres)

    string(APPEND CMAKE_C_FLAGS_INIT " ${VCPKG_C_FLAGS} ")
    string(APPEND CMAKE_CXX_FLAGS_INIT " ${VCPKG_CXX_FLAGS} ")
    string(APPEND CMAKE_C_FLAGS_DEBUG_INIT " ${VCPKG_C_FLAGS_DEBUG} ")
    string(APPEND CMAKE_CXX_FLAGS_DEBUG_INIT " ${VCPKG_CXX_FLAGS_DEBUG} ")
    string(APPEND CMAKE_C_FLAGS_RELEASE_INIT " ${VCPKG_C_FLAGS_RELEASE} ")
    string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT " ${VCPKG_CXX_FLAGS_RELEASE} ")

    string(APPEND CMAKE_MODULE_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " ${VCPKG_LINKER_FLAGS} ")
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        string(APPEND CMAKE_MODULE_LINKER_FLAGS_INIT "-static ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT "-static ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT "-static ")
    endif()
    string(APPEND CMAKE_MODULE_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_MODULE_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT " ${VCPKG_LINKER_FLAGS_RELEASE} ")
endif()
