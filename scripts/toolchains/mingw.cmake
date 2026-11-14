function(_vcpkg_validate_mingw_compiler language target_regex)
    set(_compiler_path "${CMAKE_${language}_COMPILER}")
    set(_compiler_command ${CMAKE_${language}_COMPILER})
    if(CMAKE_${language}_COMPILER_ARG1)
        list(APPEND _compiler_command "${CMAKE_${language}_COMPILER_ARG1}")
    endif()
    if((CMAKE_${language}_COMPILER_ID STREQUAL "Clang"
            OR CMAKE_${language}_COMPILER MATCHES "[Cc][Ll][Aa][Nn][Gg]")
        AND CMAKE_${language}_COMPILER_TARGET)
        list(APPEND _compiler_command "--target=${CMAKE_${language}_COMPILER_TARGET}")
    endif()
    list(APPEND _compiler_command -dumpmachine)

    execute_process(
        COMMAND ${_compiler_command}
        OUTPUT_VARIABLE _compiler_target
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE _compiler_error
        RESULT_VARIABLE _compiler_result
    )

    if(NOT _compiler_result EQUAL 0 OR NOT _compiler_target MATCHES "${target_regex}")
        if(language STREQUAL "C")
            set(_compiler_label "C")
        else()
            set(_compiler_label "C++")
        endif()

        unset(CMAKE_${language}_COMPILER CACHE)
        unset(CMAKE_${language}_COMPILER PARENT_SCOPE)

        message(FATAL_ERROR
            "The selected MinGW ${_compiler_label} compiler '${_compiler_path}' "
            "does not target ${VCPKG_TARGET_ARCHITECTURE}. "
            "Its -dumpmachine output was '${_compiler_target}'. "
            "Compiler error output: '${_compiler_error}'. "
            "Select a matching MinGW compiler or install the target-prefixed compiler."
        )
    endif()
endfunction()

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
    if(NOT DEFINED _VCPKG_MINGW_PREVIOUS_USER_MAKE_RULES_OVERRIDE_C)
        set(_VCPKG_MINGW_PREVIOUS_USER_MAKE_RULES_OVERRIDE_C "${CMAKE_USER_MAKE_RULES_OVERRIDE_C}")
    endif()
    if(NOT DEFINED _VCPKG_MINGW_PREVIOUS_USER_MAKE_RULES_OVERRIDE_CXX)
        set(_VCPKG_MINGW_PREVIOUS_USER_MAKE_RULES_OVERRIDE_CXX "${CMAKE_USER_MAKE_RULES_OVERRIDE_CXX}")
    endif()

    list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
        VCPKG_CRT_LINKAGE VCPKG_TARGET_ARCHITECTURE
        VCPKG_C_FLAGS VCPKG_CXX_FLAGS
        VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
        VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
        VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
        _VCPKG_MINGW_PREVIOUS_USER_MAKE_RULES_OVERRIDE_C
        _VCPKG_MINGW_PREVIOUS_USER_MAKE_RULES_OVERRIDE_CXX
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
        set(_VCPKG_MINGW_TARGET_REGEX "^(i[3-6]86|x86)-.*-(mingw32|windows-gnu)$")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(_VCPKG_MINGW_TARGET_REGEX "^(x86_64|amd64)-.*-(mingw32|windows-gnu)$")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(_VCPKG_MINGW_TARGET_REGEX "^(arm|armv[0-9]+)-.*-(mingw32|windows-gnu)$")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(_VCPKG_MINGW_TARGET_REGEX "^(aarch64|arm64)-.*-(mingw32|windows-gnu)$")
    else()
        message(FATAL_ERROR "Unsupported MinGW target architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    # Prefer target-prefixed MinGW tools, but also support toolchains whose
    # executables are named simply gcc, g++, and windres.
    find_program(CMAKE_C_COMPILER NAMES "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-gcc" gcc)
    find_program(CMAKE_CXX_COMPILER NAMES "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-g++" g++)
    find_program(CMAKE_RC_COMPILER NAMES "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-windres" windres)

    # The language-specific rules hook runs for both project() and later
    # enable_language() calls. Reusing this file keeps validation self-contained.
    set(CMAKE_USER_MAKE_RULES_OVERRIDE_C "${CMAKE_CURRENT_LIST_FILE}")
    set(CMAKE_USER_MAKE_RULES_OVERRIDE_CXX "${CMAKE_CURRENT_LIST_FILE}")

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

# CMake includes this file through CMAKE_USER_MAKE_RULES_OVERRIDE_<LANG> after
# each language has been enabled. This also covers standalone enable_language()
# calls, unlike CMAKE_PROJECT_INCLUDE.
get_property(_VCPKG_MINGW_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)

foreach(_vcpkg_mingw_language IN ITEMS C CXX)
    list(FIND _VCPKG_MINGW_ENABLED_LANGUAGES "${_vcpkg_mingw_language}" _vcpkg_mingw_language_index)
    if(NOT _vcpkg_mingw_language_index EQUAL -1)
        get_property(
            _vcpkg_mingw_language_hook_done
            GLOBAL PROPERTY "_VCPKG_MINGW_${_vcpkg_mingw_language}_HOOK_DONE"
        )
        if(NOT _vcpkg_mingw_language_hook_done)
            set_property(
                GLOBAL PROPERTY "_VCPKG_MINGW_${_vcpkg_mingw_language}_HOOK_DONE"
                TRUE
            )

            # Preserve any language-specific override previously supplied by the
            # project or toolchain. CMake has already handled the generic override.
            if(_VCPKG_MINGW_PREVIOUS_USER_MAKE_RULES_OVERRIDE_${_vcpkg_mingw_language}
                AND NOT _VCPKG_MINGW_PREVIOUS_USER_MAKE_RULES_OVERRIDE_${_vcpkg_mingw_language} STREQUAL CMAKE_CURRENT_LIST_FILE)
                include("${_VCPKG_MINGW_PREVIOUS_USER_MAKE_RULES_OVERRIDE_${_vcpkg_mingw_language}}")
            endif()

            # try_compile() reloads the toolchain in a child project. Do not fail
            # there: validate and clear the compiler in the owning configure.
            if(NOT IN_TRY_COMPILE)
                _vcpkg_validate_mingw_compiler(
                    "${_vcpkg_mingw_language}"
                    "${_VCPKG_MINGW_TARGET_REGEX}"
                )
            endif()
        endif()
    endif()
endforeach()
