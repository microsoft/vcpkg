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
            message(FATAL_ERROR
                "The fallback MinGW ${language} compiler '${compiler}' is incompatible with "
                "the requested ${VCPKG_TARGET_ARCHITECTURE} target. "
                "Its -dumpmachine output was '${_compiler_target}'. "
                "Select a matching MinGW compiler or install the target-prefixed compiler."
            )
        endif()
    endfunction()

    find_program(CMAKE_C_COMPILER NAMES "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-gcc")
    if(NOT CMAKE_C_COMPILER)
        find_program(CMAKE_C_COMPILER NAMES gcc)
        if(CMAKE_C_COMPILER)
            _vcpkg_validate_mingw_compiler("${CMAKE_C_COMPILER}" "C" "${_VCPKG_MINGW_TARGET_REGEX}")
        endif()
    endif()

    find_program(CMAKE_CXX_COMPILER NAMES "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-g++")
    if(NOT CMAKE_CXX_COMPILER)
        find_program(CMAKE_CXX_COMPILER NAMES g++)
        if(CMAKE_CXX_COMPILER)
            _vcpkg_validate_mingw_compiler("${CMAKE_CXX_COMPILER}" "C++" "${_VCPKG_MINGW_TARGET_REGEX}")
        endif()
    endif()

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

