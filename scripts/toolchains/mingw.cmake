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

    set(_vcpkg_mingw_tool_prefix "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32-")

    foreach(lang C CXX)
      set(CMAKE_${lang}_COMPILER_TARGET "${CMAKE_SYSTEM_PROCESSOR}-w64-windows-gnu" CACHE STRING "")
    endforeach()

    # Select and validate MinGW compilers.
    #
    # Compiler discovery happens while this toolchain file is loaded, because
    # that is the only point where a selection can influence CMake's own
    # CMakeDetermine<LANG>Compiler.cmake logic (otherwise CMake silently falls
    # back to the first `cc`/`gcc` found on the PATH, which is the native host
    # compiler when building MinGW ports from a non-Windows host).
    #
    # Target validation happens per language, at the correct point of CMake's
    # compiler initialization: the generated <LANG>-override.cmake wrappers are
    # registered as CMAKE_USER_MAKE_RULES_OVERRIDE_<LANG> and are therefore
    # included by CMakeC<CXX>Information.cmake after the compiler has been
    # determined but before any ABI or feature check try_compile() runs. Each
    # language initializes its own override, so neither language is validated
    # (or rejected) before it is actually enabled.
    #
    # try_compile() projects forward CMAKE_USER_MAKE_RULES_OVERRIDE_<LANG> to
    # their children by writing it into the generated CMakeLists.txt, so the
    # wrappers are re-included in nested configurations. There they only run
    # the user's original override file; validation is skipped to avoid
    # recursive probes and false failures (the parent already validated the
    # compiler, and IN_TRY_COMPILE configurations receive the parent's compiler
    # selection).

    function(z_vcpkg_mingw_find_compiler lang env_var)
        # Never replace an explicitly configured compiler selection
        # (CMAKE_<LANG>_COMPILER set as a cache or normal variable).
        if(CMAKE_${lang}_COMPILER)
            return()
        endif()

        if(lang STREQUAL "C")
            set(z_vcpkg_mingw_prefixed_names
                "${_vcpkg_mingw_tool_prefix}gcc"
                "${_vcpkg_mingw_tool_prefix}gcc-posix"
                "${_vcpkg_mingw_tool_prefix}gcc-win32"
                "${_vcpkg_mingw_tool_prefix}clang")
            set(z_vcpkg_mingw_plain_names "gcc")
        else()
            set(z_vcpkg_mingw_prefixed_names
                "${_vcpkg_mingw_tool_prefix}g++"
                "${_vcpkg_mingw_tool_prefix}g++-posix"
                "${_vcpkg_mingw_tool_prefix}g++-win32"
                "${_vcpkg_mingw_tool_prefix}clang++")
            set(z_vcpkg_mingw_plain_names "g++")
        endif()

        # find_program() considers one name at a time and searches every
        # directory for it, so the architecture-prefixed names take precedence
        # over everything else on the PATH.
        find_program(z_vcpkg_mingw_compiler NAMES ${z_vcpkg_mingw_prefixed_names})
        if(NOT z_vcpkg_mingw_compiler AND "$ENV{${env_var}}" STREQUAL "")
            # No prefixed compiler was found. If CC/CXX is set, leave the
            # selection to CMake so that the environment choice is preserved;
            # otherwise fall back to the conventional unprefixed executable
            # names (as used for example by the MinGW distributions bundled
            # with IDEs). The fallback is validated via -dumpmachine below.
            find_program(z_vcpkg_mingw_compiler NAMES ${z_vcpkg_mingw_plain_names})
        endif()

        if(z_vcpkg_mingw_compiler)
            set(CMAKE_${lang}_COMPILER "${z_vcpkg_mingw_compiler}" CACHE FILEPATH
                "${lang} compiler selected by the vcpkg MinGW toolchain")
            # Remember that this cache entry was created automatically by the
            # toolchain, so that a failed target validation can remove exactly
            # this entry without ever touching an explicit user selection.
            set(Z_VCPKG_MINGW_AUTO_${lang}_COMPILER "${z_vcpkg_mingw_compiler}" CACHE INTERNAL
                "vcpkg MinGW toolchain: automatically selected ${lang} compiler")
        endif()
        unset(z_vcpkg_mingw_compiler CACHE)
    endfunction()

    function(z_vcpkg_mingw_resolve_include_path override_value out_var)
        # Resolve a CMAKE_USER_MAKE_RULES_OVERRIDE(_<LANG>) value the same way
        # include() resolves it: absolute paths are used as they are; relative
        # values are first searched as a module ("<value>.cmake" inside the
        # CMAKE_MODULE_PATH entries) and are then interpreted relative to the
        # current source directory. The resolved result is used for nested
        # try_compile() configurations, whose working directories differ from
        # the parent project's.
        if("${override_value}" STREQUAL "")
            set("${out_var}" "" PARENT_SCOPE)
            return()
        endif()
        set(z_vcpkg_mingw_resolved "${override_value}")
        if(NOT IS_ABSOLUTE "${override_value}")
            set(z_vcpkg_mingw_resolved "")
            foreach(z_vcpkg_mingw_module_dir IN LISTS CMAKE_MODULE_PATH)
                if(z_vcpkg_mingw_module_dir AND EXISTS "${z_vcpkg_mingw_module_dir}/${override_value}.cmake")
                    set(z_vcpkg_mingw_resolved "${z_vcpkg_mingw_module_dir}/${override_value}.cmake")
                    break()
                endif()
            endforeach()
            if(NOT z_vcpkg_mingw_resolved AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${override_value}")
                set(z_vcpkg_mingw_resolved "${CMAKE_CURRENT_SOURCE_DIR}/${override_value}")
            endif()
            if(NOT z_vcpkg_mingw_resolved)
                # Keep the original value so that the parent configuration
                # reports the same include() error it would report without
                # this toolchain.
                set(z_vcpkg_mingw_resolved "${override_value}")
            endif()
        endif()
        set("${out_var}" "${z_vcpkg_mingw_resolved}" PARENT_SCOPE)
    endfunction()

    function(z_vcpkg_mingw_validate_target lang)
        if(NOT CMAKE_${lang}_COMPILER)
            return()
        endif()

        # Accepted -dumpmachine patterns per requested vcpkg architecture.
        # Canonical MinGW triples are <arch>-w64-mingw32 (GCC toolchains) and
        # <arch>-w64-windows-gnu (LLVM-MinGW and Clang with an explicit
        # --target). The vendor component may be absent or "pc"/"unknown".
        # The pattern is deliberately anchored so that Linux or other
        # non-Windows triples are never accepted.
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(z_vcpkg_mingw_arch_pattern "i[3-9]86")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(z_vcpkg_mingw_arch_pattern "(x86_64|amd64)")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
            set(z_vcpkg_mingw_arch_pattern "(arm|armv[67])")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            set(z_vcpkg_mingw_arch_pattern "(aarch64|arm64)")
        else()
            return()
        endif()
        set(z_vcpkg_mingw_triple_pattern
            "^${z_vcpkg_mingw_arch_pattern}(-(w64|pc|unknown))?-(mingw32|windows-gnu)$")

        set(z_vcpkg_mingw_command "${CMAKE_${lang}_COMPILER}")
        set(z_vcpkg_mingw_arg1 "${CMAKE_${lang}_COMPILER_ARG1}")
        if(z_vcpkg_mingw_arg1)
            # CMAKE_<LANG>_COMPILER_ARG1 may contain several space separated
            # arguments (for example "-m64 -fwrapv"); never pass it as one.
            separate_arguments(z_vcpkg_mingw_arg1 NATIVE_COMMAND "${z_vcpkg_mingw_arg1}")
            list(APPEND z_vcpkg_mingw_command ${z_vcpkg_mingw_arg1})
        endif()
        # Clang is inherently a cross compiler and reports its host triple
        # unless --target is passed, so query the configured target explicitly.
        if(CMAKE_${lang}_COMPILER_TARGET AND CMAKE_${lang}_COMPILER_ID MATCHES "^(AppleClang|Clang|IntelLLVM)$")
            list(APPEND z_vcpkg_mingw_command "--target=${CMAKE_${lang}_COMPILER_TARGET}")
        endif()
        list(APPEND z_vcpkg_mingw_command "-dumpmachine")

        execute_process(
            COMMAND ${z_vcpkg_mingw_command}
            OUTPUT_VARIABLE z_vcpkg_mingw_target
            ERROR_VARIABLE z_vcpkg_mingw_target_error
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE z_vcpkg_mingw_target_result)

        set(z_vcpkg_mingw_reason "")
        if(NOT z_vcpkg_mingw_target_result STREQUAL "0")
            set(z_vcpkg_mingw_reason
                "querying it with -dumpmachine failed with result '${z_vcpkg_mingw_target_result}'")
            if(z_vcpkg_mingw_target_error)
                string(APPEND z_vcpkg_mingw_reason ":\n  ${z_vcpkg_mingw_target_error}")
            endif()
        elseif(NOT z_vcpkg_mingw_target)
            set(z_vcpkg_mingw_reason "it reported no target (-dumpmachine output was empty)")
        elseif(NOT z_vcpkg_mingw_target MATCHES "${z_vcpkg_mingw_triple_pattern}")
            set(z_vcpkg_mingw_reason
                "it targets '${z_vcpkg_mingw_target}', which is not a MinGW (Windows GNU) target for the requested architecture")
        endif()

        if(z_vcpkg_mingw_reason)
            string(REPLACE ";" " " z_vcpkg_mingw_command_text "${z_vcpkg_mingw_command}")
            set(z_vcpkg_mingw_removed_notice "")
            if(NOT "${Z_VCPKG_MINGW_AUTO_${lang}_COMPILER}" STREQUAL ""
                    AND "${CMAKE_${lang}_COMPILER}" STREQUAL "${Z_VCPKG_MINGW_AUTO_${lang}_COMPILER}")
                # Remove the toolchain-selected compiler from the cache so the
                # next configure re-runs the discovery instead of reusing the
                # rejected find_program() result. The generated compiler
                # information file must go too: it still records the rejected
                # compiler and would otherwise short-circuit the next
                # detection. Explicit user selections (CMAKE_<LANG>_COMPILER,
                # CC, CXX) are never removed.
                unset(CMAKE_${lang}_COMPILER CACHE)
                unset(Z_VCPKG_MINGW_AUTO_${lang}_COMPILER CACHE)
                if(DEFINED CMAKE_PLATFORM_INFO_DIR)
                    file(REMOVE "${CMAKE_PLATFORM_INFO_DIR}/CMake${lang}Compiler.cmake")
                endif()
                set(z_vcpkg_mingw_removed_notice
                    "  The automatically selected compiler was removed from the CMake cache;\n  install or select a matching compiler and re-run CMake.\n")
                # Also drop automatically selected (and not yet validated)
                # compilers of the other languages, so that a corrected
                # environment is re-detected for every language on the next
                # configure instead of only for the rejected one.
                foreach(z_vcpkg_mingw_other C CXX)
                    if(NOT z_vcpkg_mingw_other STREQUAL "${lang}"
                            AND NOT Z_VCPKG_MINGW_${z_vcpkg_mingw_other}_VALIDATED
                            AND NOT "${Z_VCPKG_MINGW_AUTO_${z_vcpkg_mingw_other}_COMPILER}" STREQUAL ""
                            AND "${CMAKE_${z_vcpkg_mingw_other}_COMPILER}" STREQUAL "${Z_VCPKG_MINGW_AUTO_${z_vcpkg_mingw_other}_COMPILER}")
                        unset(CMAKE_${z_vcpkg_mingw_other}_COMPILER CACHE)
                        unset(Z_VCPKG_MINGW_AUTO_${z_vcpkg_mingw_other}_COMPILER CACHE)
                        if(DEFINED CMAKE_PLATFORM_INFO_DIR)
                            file(REMOVE "${CMAKE_PLATFORM_INFO_DIR}/CMake${z_vcpkg_mingw_other}Compiler.cmake")
                        endif()
                    endif()
                endforeach()
                unset(z_vcpkg_mingw_other)
            endif()
            message(FATAL_ERROR
                "vcpkg MinGW toolchain: rejecting the ${lang} compiler because ${z_vcpkg_mingw_reason}.\n"
                "  Selected compiler (CMAKE_${lang}_COMPILER): ${CMAKE_${lang}_COMPILER}\n"
                "  Compiler ID: ${CMAKE_${lang}_COMPILER_ID}\n"
                "  Compiler arguments (CMAKE_${lang}_COMPILER_ARG1): ${CMAKE_${lang}_COMPILER_ARG1}\n"
                "  Probe command: ${z_vcpkg_mingw_command_text}\n"
                "  Probe output: ${z_vcpkg_mingw_target}\n"
                "  Requested architecture (VCPKG_TARGET_ARCHITECTURE): ${VCPKG_TARGET_ARCHITECTURE}\n"
                "  Accepted target triples match: ${z_vcpkg_mingw_triple_pattern}\n"
                "${z_vcpkg_mingw_removed_notice}"
                "Select a MinGW-w64 compiler targeting ${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32, for example by\n"
                "putting its bin directory on the PATH or by setting CMAKE_${lang}_COMPILER, CC or CXX, then re-run CMake.")
            return()
        endif()

        message(STATUS
            "vcpkg MinGW toolchain: ${lang} compiler '${CMAKE_${lang}_COMPILER}' targets '${z_vcpkg_mingw_target}' (requested architecture: ${VCPKG_TARGET_ARCHITECTURE})")
    endfunction()

    get_property(z_vcpkg_mingw_in_try_compile GLOBAL PROPERTY IN_TRY_COMPILE)
    if(NOT z_vcpkg_mingw_in_try_compile)
        # Discover the C and CXX compilers for this (parent) configuration.
        z_vcpkg_mingw_find_compiler(C CC)
        z_vcpkg_mingw_find_compiler(CXX CXX)

        # Register the per-language override wrappers. They are generated in
        # the build directory at configure time (no tracked helper files) and
        # preserve any user-provided CMAKE_USER_MAKE_RULES_OVERRIDE,
        # CMAKE_USER_MAKE_RULES_OVERRIDE_C and CMAKE_USER_MAKE_RULES_OVERRIDE_CXX
        # settings: the original values are included exactly once at the same
        # initialization point at which CMake would have included them.
        set(z_vcpkg_mingw_wrapper_dir "${CMAKE_BINARY_DIR}/vcpkg-mingw")
        foreach(z_vcpkg_mingw_lang C CXX)
            set(z_vcpkg_mingw_override "${CMAKE_USER_MAKE_RULES_OVERRIDE_${z_vcpkg_mingw_lang}}")
            set(z_vcpkg_mingw_generic_override "${CMAKE_USER_MAKE_RULES_OVERRIDE}")
            set(z_vcpkg_mingw_wrapper "${z_vcpkg_mingw_wrapper_dir}/${z_vcpkg_mingw_lang}-override.cmake")
            if("${z_vcpkg_mingw_override}" STREQUAL "${z_vcpkg_mingw_wrapper}"
                    OR "${z_vcpkg_mingw_generic_override}" STREQUAL "${z_vcpkg_mingw_wrapper}")
                # Pathological self reference; treat as absent.
                set(z_vcpkg_mingw_override "")
                set(z_vcpkg_mingw_generic_override "")
            endif()
            z_vcpkg_mingw_resolve_include_path("${z_vcpkg_mingw_override}" z_vcpkg_mingw_override_abs)
            z_vcpkg_mingw_resolve_include_path("${z_vcpkg_mingw_generic_override}" z_vcpkg_mingw_generic_override_abs)
            file(WRITE "${z_vcpkg_mingw_wrapper}" "# Generated by the vcpkg MinGW toolchain; do not edit.
# Included by CMake when the ${z_vcpkg_mingw_lang} language is initialized
# (CMAKE_USER_MAKE_RULES_OVERRIDE_${z_vcpkg_mingw_lang}). Runs the user's
# original rules override, then validates the selected MinGW compiler.
get_property(z_vcpkg_mingw_in_try_compile GLOBAL PROPERTY IN_TRY_COMPILE)
if(z_vcpkg_mingw_in_try_compile)
    if(NOT \"${z_vcpkg_mingw_override_abs}\" STREQUAL \"\")
        include(\"${z_vcpkg_mingw_override_abs}\")
    elseif(NOT \"${z_vcpkg_mingw_generic_override_abs}\" STREQUAL \"\" AND NOT DEFINED CMAKE_USER_MAKE_RULES_OVERRIDE)
        include(\"${z_vcpkg_mingw_generic_override_abs}\")
    endif()
else()
    if(NOT \"${z_vcpkg_mingw_override}\" STREQUAL \"\")
        # Include the original value verbatim so that include() resolves
        # relative paths exactly as CMake would have resolved them.
        include(\"${z_vcpkg_mingw_override}\")
    endif()
    z_vcpkg_mingw_validate_target(${z_vcpkg_mingw_lang})
    set(Z_VCPKG_MINGW_${z_vcpkg_mingw_lang}_VALIDATED TRUE)
endif()
")
            set(CMAKE_USER_MAKE_RULES_OVERRIDE_${z_vcpkg_mingw_lang} "${z_vcpkg_mingw_wrapper}")
        endforeach()
        unset(z_vcpkg_mingw_wrapper_dir)
        unset(z_vcpkg_mingw_lang)
        unset(z_vcpkg_mingw_override)
        unset(z_vcpkg_mingw_override_abs)
        unset(z_vcpkg_mingw_generic_override)
        unset(z_vcpkg_mingw_generic_override_abs)
        unset(z_vcpkg_mingw_wrapper)
    endif()
    unset(z_vcpkg_mingw_in_try_compile)

    find_program(CMAKE_RC_COMPILER "${_vcpkg_mingw_tool_prefix}windres")
    if(NOT CMAKE_RC_COMPILER)
        find_program(CMAKE_RC_COMPILER "windres")
    endif()

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
