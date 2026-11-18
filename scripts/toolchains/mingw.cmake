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
    # Forward everything a try_compile probe needs, so nested probes
    # (probes of probes) inherit it too: the sub-configuration marker, the
    # selected compilers and their ARG1 values. The user rule overrides
    # are appended at the end of this file, once their values are known:
    # only values that resolve to real files can be forwarded (probes run
    # with a different working directory and without CMAKE_MODULE_PATH, so
    # a module name would not resolve there).
    list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
        z_vcpkg_mingw_forward
        z_vcpkg_mingw_user_override
        z_vcpkg_mingw_user_override_C
        z_vcpkg_mingw_user_override_CXX
        CMAKE_C_COMPILER CMAKE_CXX_COMPILER
        CMAKE_C_COMPILER_ARG1 CMAKE_CXX_COMPILER_ARG1
        CMAKE_RC_COMPILER)
    list(REMOVE_DUPLICATES CMAKE_TRY_COMPILE_PLATFORM_VARIABLES)

    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
    endif()

    # Need to override MinGW from VCPKG_CMAKE_SYSTEM_NAME: vcpkg configures
    # ports with -DCMAKE_SYSTEM_NAME=MinGW, which CMake does not recognize
    # as a platform (WIN32 would be false and shared libraries would be
    # named .so instead of .dll). Only a forced cache set overrides a cache
    # entry supplied on the command line.
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

# ---------------------------------------------------------------------------
# Everything below is re-evaluated at every toolchain load, including the
# loads triggered by each enable_language() call. All of it is idempotent
# within a single configure run.
# ---------------------------------------------------------------------------

# A sub-configuration is a try_compile() probe, or any nested configure that
# inherited this toolchain's platform variables. z_vcpkg_mingw_forward is set
# as a normal variable (the value to forward) only in a parent configuration;
# nested configures receive it as a cache entry through
# CMAKE_TRY_COMPILE_PLATFORM_VARIABLES. z_vcpkg_mingw_is_parent marks the
# process that created these variables, and is what the generated wrappers
# use to tell the parent from a probe.
if(NOT z_vcpkg_mingw_is_parent AND z_vcpkg_mingw_forward)
    set(z_vcpkg_mingw_subconfig TRUE)
endif()

# Target architecture used for discovery and validation.
set(z_vcpkg_mingw_arch "${VCPKG_TARGET_ARCHITECTURE}")
if(NOT z_vcpkg_mingw_arch AND CMAKE_SYSTEM_PROCESSOR)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
        set(z_vcpkg_mingw_arch "x64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(i[3-6]86|x86|X86)$")
        set(z_vcpkg_mingw_arch "x86")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|ARM64)$")
        set(z_vcpkg_mingw_arch "arm64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(armv7|ARM)$")
        set(z_vcpkg_mingw_arch "arm")
    endif()
endif()

set(z_vcpkg_mingw_prefixes "")
if(z_vcpkg_mingw_arch STREQUAL "x64")
    list(APPEND z_vcpkg_mingw_prefixes "x86_64-w64-mingw32" "x86_64-w64-mingw32ucrt")
elseif(z_vcpkg_mingw_arch STREQUAL "x86")
    list(APPEND z_vcpkg_mingw_prefixes "i686-w64-mingw32" "i686-w64-mingw32ucrt")
elseif(z_vcpkg_mingw_arch STREQUAL "arm")
    list(APPEND z_vcpkg_mingw_prefixes "armv7-w64-mingw32")
elseif(z_vcpkg_mingw_arch STREQUAL "arm64")
    list(APPEND z_vcpkg_mingw_prefixes "aarch64-w64-mingw32")
elseif(NOT z_vcpkg_mingw_prefixes AND CMAKE_SYSTEM_PROCESSOR)
    list(APPEND z_vcpkg_mingw_prefixes "${CMAKE_SYSTEM_PROCESSOR}-w64-mingw32")
endif()

if(NOT z_vcpkg_mingw_subconfig)
    # --- parent configuration only ----------------------------------------
    # Generate the shared validation helpers into the build directory (never
    # into the repository) and load them.
    set(z_vcpkg_mingw_common "${CMAKE_BINARY_DIR}/z_vcpkg_mingw_common.cmake")
    file(WRITE "${z_vcpkg_mingw_common}" [===[
# Generated by scripts/toolchains/mingw.cmake. Do not edit.
# Shared compiler validation helpers for the vcpkg MinGW toolchain.

# Probe a candidate compiler with `-dumpmachine` and check the reported
# target triple against the requested architecture. Multi-argument
# CMAKE_<LANG>_COMPILER_ARG1 values are split with separate_arguments and
# passed to execute_process as a proper argument list, never via a shell.
function(z_vcpkg_mingw_probe z_lang z_compiler z_out_ok z_out_triple z_out_msg)
    set(z_ok FALSE)
    set(z_triple "")
    set(z_msg "")
    set(z_requested "${z_vcpkg_mingw_arch}")
    if(z_lang STREQUAL "C")
        set(z_env_name "CC")
    else()
        set(z_env_name "CXX")
    endif()
    if(NOT z_requested)
        # No target architecture is known; validation is not possible.
        set(z_ok TRUE)
    else()
        set(z_abs "${z_compiler}")
        if(NOT EXISTS "${z_abs}")
            find_program(z_vcpkg_mingw_probe_resolve NAMES "${z_compiler}")
            if(z_vcpkg_mingw_probe_resolve)
                set(z_abs "${z_vcpkg_mingw_probe_resolve}")
            endif()
            unset(z_vcpkg_mingw_probe_resolve CACHE)
        endif()
        if(NOT EXISTS "${z_abs}")
            set(z_msg "vcpkg mingw toolchain: the ${z_lang} compiler\n  ${z_compiler}\ndoes not exist. Set CMAKE_${z_lang}_COMPILER (or ${z_env_name}) to a MinGW-w64 compiler, for example ${z_requested}-w64-mingw32-gcc.")
        else()
            set(z_args "")
            if(CMAKE_${z_lang}_COMPILER_ARG1)
                separate_arguments(z_args NATIVE_COMMAND "${CMAKE_${z_lang}_COMPILER_ARG1}")
            endif()
            # Clang answers -dumpmachine with its default target; ask for the
            # requested one explicitly so legitimate Clang-MinGW triples are
            # not falsely rejected. CMAKE_SYSTEM_PROCESSOR is never used as
            # proof of the target; only the compiler's own answer is.
            get_filename_component(z_name "${z_abs}" NAME_WE)
            if(z_name MATCHES "clang"
               AND CMAKE_${z_lang}_COMPILER_TARGET
               AND NOT "${z_args}" MATCHES "-target")
                list(APPEND z_args "--target=${CMAKE_${z_lang}_COMPILER_TARGET}")
            endif()
            execute_process(
                COMMAND "${z_abs}" ${z_args} -dumpmachine
                OUTPUT_VARIABLE z_dump
                ERROR_VARIABLE z_err
                RESULT_VARIABLE z_rc
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_STRIP_TRAILING_WHITESPACE
                TIMEOUT 15)
            string(TOLOWER "${z_dump}" z_dump_l)
            set(z_machine "")
            if(z_requested STREQUAL "x64")
                set(z_machine "(x86_64|amd64)")
            elseif(z_requested STREQUAL "x86")
                set(z_machine "(i[3-6]86)")
            elseif(z_requested STREQUAL "arm")
                set(z_machine "(armv7)")
            elseif(z_requested STREQUAL "arm64")
                set(z_machine "(aarch64)")
            endif()
            # The acceptance pattern deliberately does not admit Linux,
            # Cygwin, Darwin or MSVC triples: the tail must name a MinGW or
            # Windows-GNU environment.
            if(z_rc EQUAL 0 AND z_dump_l MATCHES "^${z_machine}(-[a-z0-9_.]+)*-(mingw32|mingw32ucrt|windows-gnu)$")
                set(z_ok TRUE)
                set(z_triple "${z_dump}")
            else()
                string(REPLACE ";" " " z_args_show "${z_args}")
                set(z_msg "vcpkg mingw toolchain: the ${z_lang} compiler\n  ${z_compiler}\nreports the target '${z_dump}', which is not a Windows GNU (MinGW) compiler for the requested architecture '${z_requested}'.\nProbe: '${z_abs}' ${z_args_show} -dumpmachine\nExit code: ${z_rc}\nOutput:\n${z_err}\nInstall a MinGW-w64 compiler (for example ${z_requested}-w64-mingw32-gcc) or point CMAKE_${z_lang}_COMPILER or ${z_env_name} at one.")
            endif()
        endif()
    endif()
    set(${z_out_ok} "${z_ok}" PARENT_SCOPE)
    set(${z_out_triple} "${z_triple}" PARENT_SCOPE)
    set(${z_out_msg} "${z_msg}" PARENT_SCOPE)
endfunction()

# Validate at the correct stage (language initialization): fire the recorded
# diagnostic on failure. If the failing compiler was selected by CMake's own
# default search (not by the user, not by this toolchain), remove it from the
# cache so that a corrected environment can reconfigure in the same build
# directory.
function(z_vcpkg_mingw_validate z_lang z_compiler)
    z_vcpkg_mingw_probe("${z_lang}" "${z_compiler}" z_ok z_triple z_msg)
    set(z_vcpkg_mingw_${z_lang}_validated 1 CACHE INTERNAL "vcpkg mingw: ${z_lang} compiler validated")
    if(NOT z_ok)
        z_vcpkg_mingw_cleanup_determine_owned()
        message(FATAL_ERROR "${z_msg}")
    endif()
endfunction()

# Before a fatal diagnostic ends the configure, remove every compiler entry
# that CMake's own default search placed in the cache during this run (never
# a user's explicit selection, never one of this toolchain's validated
# selections), so that a corrected environment can reconfigure in the same
# build directory. Runs for all languages: the configure is ending anyway,
# and a language whose initialization point was never reached must not leave
# a rejected compiler behind either.
function(z_vcpkg_mingw_cleanup_determine_owned)
    foreach(z_lang C CXX)
        if(z_vcpkg_mingw_${z_lang}_determine_owns AND CMAKE_${z_lang}_COMPILER)
            unset(CMAKE_${z_lang}_COMPILER CACHE)
            unset(z_vcpkg_mingw_${z_lang}_determine_compiler CACHE)
            unset(z_vcpkg_mingw_${z_lang}_determine_owns CACHE)
        endif()
    endforeach()
endfunction()
]===])
    include("${z_vcpkg_mingw_common}")

    # Validation results must not leak from a previous configure run: a cached
    # automatic fallback is revalidated on every reconfigure.
    foreach(z_mw_lang C CXX)
        unset(z_vcpkg_mingw_${z_mw_lang}_validated CACHE)
    endforeach()

    # Preserve user rule overrides: resolve them for the probes (which run
    # with a different working directory) and remember the user's own files
    # so the per-language validation wrappers can chain to them. A value is
    # resolved exactly the way include() resolves it: absolute paths are
    # used as they are; a relative value is searched as a module
    # ("<value>.cmake" inside the CMAKE_MODULE_PATH entries), then relative
    # to the current source directory, then relative to the working
    # directory. A value that cannot be resolved is kept verbatim, so the
    # parent configuration reports the same include() error it would report
    # without this toolchain (CMake resolves module names itself at the
    # language initialization point); it is not forwarded to probes, which
    # could not resolve it. Our own wrapper paths (from a previous run) are
    # never mistaken for user files.
    function(z_vcpkg_mingw_resolve_override z_value z_out_var)
        set(z_res "${z_value}")
        if(NOT IS_ABSOLUTE "${z_value}")
            set(z_res "")
            foreach(z_dir IN LISTS CMAKE_MODULE_PATH)
                if(z_dir AND EXISTS "${z_dir}/${z_value}.cmake")
                    set(z_res "${z_dir}/${z_value}.cmake")
                    break()
                endif()
            endforeach()
            if(NOT z_res AND CMAKE_CURRENT_SOURCE_DIR AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${z_value}")
                set(z_res "${CMAKE_CURRENT_SOURCE_DIR}/${z_value}")
            endif()
            if(NOT z_res AND EXISTS "${z_value}")
                get_filename_component(z_res "${z_value}" ABSOLUTE)
            endif()
            if(NOT z_res)
                set(z_res "${z_value}")
            endif()
        endif()
        set(${z_out_var} "${z_res}" PARENT_SCOPE)
    endfunction()

    set(z_vcpkg_mingw_user_override "")
    if(CMAKE_USER_MAKE_RULES_OVERRIDE)
        z_vcpkg_mingw_resolve_override("${CMAKE_USER_MAKE_RULES_OVERRIDE}" z_mw_resolved)
        set(z_vcpkg_mingw_user_override "${z_mw_resolved}")
        # Make the resolved value effective (probes run with a different
        # working directory and cannot resolve module names).
        set(CMAKE_USER_MAKE_RULES_OVERRIDE "${z_mw_resolved}")
    endif()
    foreach(z_mw_lang C CXX)
        set(z_vcpkg_mingw_user_override_${z_mw_lang} "")
        if(CMAKE_USER_MAKE_RULES_OVERRIDE_${z_mw_lang})
            if(NOT "${CMAKE_USER_MAKE_RULES_OVERRIDE_${z_mw_lang}}" STREQUAL "${z_vcpkg_mingw_${z_mw_lang}_override_marker}")
                z_vcpkg_mingw_resolve_override("${CMAKE_USER_MAKE_RULES_OVERRIDE_${z_mw_lang}}" z_mw_resolved)
                set(z_vcpkg_mingw_user_override_${z_mw_lang} "${z_mw_resolved}")
                # Make the resolved value effective (probes run with a
                # different working directory and cannot resolve module
                # names).
                set(CMAKE_USER_MAKE_RULES_OVERRIDE_${z_mw_lang} "${z_mw_resolved}")
            endif()
        endif()
    endforeach()

    # Mark this process as the parent configuration and provide the value
    # that gets forwarded to nested configures. Cache variables cannot hold
    # newlines, so deferred diagnostics are stored with escaped newlines and
    # decoded where they are reported.
    set(z_vcpkg_mingw_is_parent 1)
    set(z_vcpkg_mingw_forward 1)
endif()

# ---------------------------------------------------------------------------
# Compiler discovery and validation for C and C++, each handled at its own
# enable_language() initialization point.
#
# Discovery order, per language:
#   1. an architecture-prefixed executable (x86_64-w64-mingw32-gcc, ...);
#   2. the CC/CXX environment variables -- an explicitly supplied compiler
#      outranks the unprefixed search, exactly as in the base toolchain
#      (where CMake's own CC/CXX handling runs before its default name
#      search), so an unprefixed gcc/g++ found on the search paths never
#      silently replaces the compiler the user asked for. The value may be
#      a full command line, e.g. CC="clang.exe --target=x86_64-w64-windows-gnu";
#      the executable and its arguments are split the same way CMake's own
#      CC/CXX handling splits them, the arguments becoming
#      CMAKE_<LANG>_COMPILER_ARG1;
#   3. an unprefixed gcc/g++ found on the search paths.
# An explicitly set CMAKE_<LANG>_COMPILER is honored and never overwritten;
# in particular a native host compiler never silently overrides an explicit
# MinGW selection. Every candidate accepted into the cache is validated with
# `-dumpmachine`; rejected candidates are removed from the cache so that
# find_program cannot reuse them. Diagnostics for a language are deferred to
# that language's own initialization point, so a compiler for a language that
# is never enabled is neither searched for nor rejected. A diagnostic
# recorded for a rejected candidate is discarded as soon as a later candidate
# validates, so a valid fallback is never rejected because an earlier
# candidate was unsuitable. A rejected CC/CXX selection is terminal: the
# user's explicit choice is never silently replaced by a compiler from a
# later rung.
# ---------------------------------------------------------------------------
foreach(z_mw_lang C CXX)
    if(z_mw_lang STREQUAL "C")
        set(z_mw_env "CC")
        set(z_mw_plain_names "gcc")
    else()
        set(z_mw_env "CXX")
        set(z_mw_plain_names "g++")
    endif()
    set(z_mw_prefixed_names "")
    foreach(z_mw_prefix IN LISTS z_vcpkg_mingw_prefixes)
        if(z_mw_lang STREQUAL "C")
            list(APPEND z_mw_prefixed_names "${z_mw_prefix}-gcc")
        else()
            list(APPEND z_mw_prefixed_names "${z_mw_prefix}-g++")
        endif()
    endforeach()

    if(NOT z_vcpkg_mingw_${z_mw_lang}_settled)
        set(z_vcpkg_mingw_${z_mw_lang}_settled TRUE)
        # Diagnostics are recomputed from scratch on every configure run.
        unset(z_vcpkg_mingw_${z_mw_lang}_deferred_error CACHE)

        if(z_vcpkg_mingw_subconfig)
            # Sub-configurations never re-run validation and never produce
            # spurious architecture failures. A compiler forwarded from the
            # parent is used as-is; otherwise the same discovery order is
            # followed, without validation.
            if(NOT CMAKE_${z_mw_lang}_COMPILER)
                unset(z_mw_cand CACHE)
                unset(z_mw_cand)
                find_program(z_mw_cand NAMES ${z_mw_prefixed_names})
                if(NOT z_mw_cand AND NOT "$ENV{${z_mw_env}}" STREQUAL "")
                    # The environment value may be a full command line; split
                    # it the same way the parent configuration does.
                    get_filename_component(z_mw_env_prog "$ENV{${z_mw_env}}" PROGRAM PROGRAM_ARGS z_mw_env_args)
                    if(z_mw_env_args AND NOT DEFINED CMAKE_${z_mw_lang}_COMPILER_ARG1)
                        set(CMAKE_${z_mw_lang}_COMPILER_ARG1 "${z_mw_env_args}" CACHE STRING "Arguments to the ${z_mw_lang} compiler")
                    endif()
                    set(z_mw_cand "${z_mw_env_prog}")
                endif()
                if(NOT z_mw_cand)
                    unset(z_mw_cand CACHE)
                    unset(z_mw_cand)
                    find_program(z_mw_cand NAMES ${z_mw_plain_names})
                endif()
                if(z_mw_cand)
                    set(CMAKE_${z_mw_lang}_COMPILER "${z_mw_cand}" CACHE FILEPATH "")
                endif()
                unset(z_mw_cand CACHE)
                unset(z_mw_cand)
            endif()
        else()
            set(z_mw_keep FALSE)
            if(CMAKE_${z_mw_lang}_COMPILER)
                set(z_mw_cached "${CMAKE_${z_mw_lang}_COMPILER}")
                if("${z_mw_cached}" STREQUAL "${z_vcpkg_mingw_${z_mw_lang}_autoselect}"
                   OR "${z_mw_cached}" STREQUAL "${z_vcpkg_mingw_${z_mw_lang}_determine_compiler}")
                    # Selected by this toolchain or by CMake's own default
                    # search in an earlier run: it is not a user choice, so
                    # revalidate it and rediscover if it went bad.
                    if(NOT z_vcpkg_mingw_${z_mw_lang}_validated)
                        z_vcpkg_mingw_probe("${z_mw_lang}" "${z_mw_cached}" z_mw_ok z_mw_triple z_mw_msg)
                        if(z_mw_ok)
                            set(z_vcpkg_mingw_${z_mw_lang}_validated 1 CACHE INTERNAL "")
                            unset(z_vcpkg_mingw_${z_mw_lang}_deferred_error CACHE)
                        else()
                            unset(CMAKE_${z_mw_lang}_COMPILER CACHE)
                            unset(z_vcpkg_mingw_${z_mw_lang}_autoselect CACHE)
                            unset(z_vcpkg_mingw_${z_mw_lang}_determine_compiler CACHE)
                        endif()
                    endif()
                else()
                    # Explicitly set by the user: honor it, do not overwrite.
                    # Validate it, but defer the failure to the language's own
                    # initialization point so a disabled language is never
                    # rejected. A native host compiler placed here never
                    # silently overrides the explicit selection.
                    set(z_mw_keep TRUE)
                    if(NOT z_vcpkg_mingw_${z_mw_lang}_validated)
                        z_vcpkg_mingw_probe("${z_mw_lang}" "${z_mw_cached}" z_mw_ok z_mw_triple z_mw_msg)
                        if(z_mw_ok)
                            set(z_vcpkg_mingw_${z_mw_lang}_validated 1 CACHE INTERNAL "")
                            unset(z_vcpkg_mingw_${z_mw_lang}_deferred_error CACHE)
                        else()
                            string(REPLACE "\n" "\\n" z_mw_deferred "${z_mw_msg}")
                            set(z_vcpkg_mingw_${z_mw_lang}_deferred_error "${z_mw_deferred}" CACHE INTERNAL "")
                        endif()
                    endif()
                endif()
            endif()

            if(NOT z_mw_keep AND NOT CMAKE_${z_mw_lang}_COMPILER)
                # Rung 1: architecture-prefixed executables.
                unset(z_mw_cand CACHE)
                unset(z_mw_cand)
                find_program(z_mw_cand NAMES ${z_mw_prefixed_names})
                if(z_mw_cand)
                    z_vcpkg_mingw_probe("${z_mw_lang}" "${z_mw_cand}" z_mw_ok z_mw_triple z_mw_msg)
                    if(z_mw_ok)
                        set(CMAKE_${z_mw_lang}_COMPILER "${z_mw_cand}" CACHE FILEPATH "")
                        set(z_vcpkg_mingw_${z_mw_lang}_autoselect "${z_mw_cand}" CACHE INTERNAL "")
                        set(z_vcpkg_mingw_${z_mw_lang}_validated 1 CACHE INTERNAL "")
                        # A valid candidate invalidates the diagnostics
                        # recorded for the candidates of earlier rungs.
                        unset(z_vcpkg_mingw_${z_mw_lang}_deferred_error CACHE)
                        message(STATUS "vcpkg mingw toolchain: ${z_mw_lang} compiler ${z_mw_cand} (${z_mw_triple})")
                    else()
                        # Rejected: drop the cache entry so find_program cannot
                        # reuse it, and record the diagnostic (the first
                        # diagnostic wins; later rungs do not overwrite it, and
                        # a later successful candidate discards it).
                        unset(z_mw_cand CACHE)
                        unset(z_mw_cand)
                        if(NOT z_vcpkg_mingw_${z_mw_lang}_deferred_error)
                            string(REPLACE "\n" "\\n" z_mw_deferred "${z_mw_msg}")
                            set(z_vcpkg_mingw_${z_mw_lang}_deferred_error "${z_mw_deferred}" CACHE INTERNAL "")
                        endif()
                    endif()
                endif()
                unset(z_mw_cand CACHE)
                unset(z_mw_cand)

                # Rung 2: the CC/CXX environment variables. An explicitly
                # supplied compiler outranks the unprefixed search; the value
                # may be a full command line, e.g.
                # CC="clang.exe --target=x86_64-w64-windows-gnu". Split it
                # exactly the way CMake's own CC/CXX handling does: the
                # executable becomes the compiler, the remaining arguments
                # become CMAKE_<LANG>_COMPILER_ARG1 (an already defined
                # argument value is never overwritten).
                set(z_mw_env_rejected FALSE)
                if(NOT CMAKE_${z_mw_lang}_COMPILER AND NOT "$ENV{${z_mw_env}}" STREQUAL "")
                    get_filename_component(z_mw_env_prog "$ENV{${z_mw_env}}" PROGRAM PROGRAM_ARGS z_mw_env_args)
                    set(z_mw_env_arg1_set FALSE)
                    if(z_mw_env_args AND NOT DEFINED CMAKE_${z_mw_lang}_COMPILER_ARG1)
                        set(CMAKE_${z_mw_lang}_COMPILER_ARG1 "${z_mw_env_args}" CACHE STRING "Arguments to the ${z_mw_lang} compiler")
                        set(z_mw_env_arg1_set TRUE)
                    endif()
                    # Resolve a bare program name to a full path so the cache
                    # holds an absolute path; a value that cannot be resolved
                    # is probed as-is and reported as non-existent.
                    set(z_mw_env_cmd "${z_mw_env_prog}")
                    if(NOT EXISTS "${z_mw_env_cmd}")
                        unset(z_mw_env_resolve CACHE)
                        unset(z_mw_env_resolve)
                        find_program(z_mw_env_resolve NAMES "${z_mw_env_cmd}")
                        if(z_mw_env_resolve)
                            set(z_mw_env_cmd "${z_mw_env_resolve}")
                        endif()
                        unset(z_mw_env_resolve CACHE)
                        unset(z_mw_env_resolve)
                    endif()
                    z_vcpkg_mingw_probe("${z_mw_lang}" "${z_mw_env_cmd}" z_mw_ok z_mw_triple z_mw_msg)
                    if(z_mw_ok)
                        set(CMAKE_${z_mw_lang}_COMPILER "${z_mw_env_cmd}" CACHE FILEPATH "")
                        set(z_vcpkg_mingw_${z_mw_lang}_autoselect "${z_mw_env_cmd}" CACHE INTERNAL "")
                        set(z_vcpkg_mingw_${z_mw_lang}_validated 1 CACHE INTERNAL "")
                        # A valid candidate invalidates the diagnostics
                        # recorded for the candidates of earlier rungs.
                        unset(z_vcpkg_mingw_${z_mw_lang}_deferred_error CACHE)
                        message(STATUS "vcpkg mingw toolchain: ${z_mw_lang} compiler ${z_mw_env_cmd} from environment ${z_mw_env} (${z_mw_triple})")
                    else()
                        # The explicit environment selection is never silently
                        # replaced by a different compiler: its rejection is
                        # terminal and its diagnostic replaces any diagnostic
                        # recorded for an earlier candidate.
                        if(z_mw_env_arg1_set)
                            unset(CMAKE_${z_mw_lang}_COMPILER_ARG1 CACHE)
                            unset(CMAKE_${z_mw_lang}_COMPILER_ARG1)
                        endif()
                        string(REPLACE "\n" "\\n" z_mw_deferred "${z_mw_msg}")
                        set(z_vcpkg_mingw_${z_mw_lang}_deferred_error "${z_mw_deferred}" CACHE INTERNAL "")
                        set(z_mw_env_rejected TRUE)
                    endif()
                endif()

                # Rung 3: unprefixed executables, only when the environment
                # did not explicitly select a compiler.
                if(NOT z_mw_env_rejected AND NOT CMAKE_${z_mw_lang}_COMPILER)
                    unset(z_mw_cand CACHE)
                    unset(z_mw_cand)
                    find_program(z_mw_cand NAMES ${z_mw_plain_names})
                    if(z_mw_cand)
                        z_vcpkg_mingw_probe("${z_mw_lang}" "${z_mw_cand}" z_mw_ok z_mw_triple z_mw_msg)
                        if(z_mw_ok)
                            set(CMAKE_${z_mw_lang}_COMPILER "${z_mw_cand}" CACHE FILEPATH "")
                            set(z_vcpkg_mingw_${z_mw_lang}_autoselect "${z_mw_cand}" CACHE INTERNAL "")
                            set(z_vcpkg_mingw_${z_mw_lang}_validated 1 CACHE INTERNAL "")
                            # A valid candidate invalidates the diagnostics
                            # recorded for the candidates of earlier rungs.
                            unset(z_vcpkg_mingw_${z_mw_lang}_deferred_error CACHE)
                            message(STATUS "vcpkg mingw toolchain: ${z_mw_lang} compiler ${z_mw_cand} (${z_mw_triple})")
                        else()
                            # Rejected: drop the cache entry so find_program
                            # cannot reuse it, and record the diagnostic (the
                            # first diagnostic wins).
                            unset(z_mw_cand CACHE)
                            unset(z_mw_cand)
                            if(NOT z_vcpkg_mingw_${z_mw_lang}_deferred_error)
                                string(REPLACE "\n" "\\n" z_mw_deferred "${z_mw_msg}")
                                set(z_vcpkg_mingw_${z_mw_lang}_deferred_error "${z_mw_deferred}" CACHE INTERNAL "")
                            endif()
                        endif()
                    endif()
                    unset(z_mw_cand CACHE)
                    unset(z_mw_cand)
                endif()
            endif()
        endif()
    endif()
endforeach()

# ---------------------------------------------------------------------------
# Per-language validation wrappers (parent configuration only).
#
# A wrapper is registered through CMAKE_USER_MAKE_RULES_OVERRIDE_<LANG> only
# when needed: either a deferred diagnostic must fire at the language's own
# initialization point, or the discovery ladder found nothing and whatever
# CMake's own default search determines must still be validated. When a
# wrapper is not needed, the user's own override value is left completely
# untouched. Wrappers are generated into the build directory at configure
# time, never into the repository, and chain to the user's own override
# files so their rules keep applying (also inside try_compile probes, which
# receive them through CMAKE_TRY_COMPILE_PLATFORM_VARIABLES).
# ---------------------------------------------------------------------------
if(NOT z_vcpkg_mingw_subconfig)
    foreach(z_mw_lang C CXX)
        set(z_mw_wrapper "${CMAKE_BINARY_DIR}/z_vcpkg_mingw_override_${z_mw_lang}.cmake")
        if(z_vcpkg_mingw_${z_mw_lang}_deferred_error OR NOT CMAKE_${z_mw_lang}_COMPILER)
            set(z_mw_wrapper_text [===[
# Generated by scripts/toolchains/mingw.cmake. Do not edit.
# Loaded at the @LANG@ language initialization point, after the compiler has
# been determined. Fires deferred validation errors for this language only
# (languages that are never enabled are never rejected), validates compilers
# picked by CMake's own default search, and chains the user's rules.
if(NOT z_vcpkg_mingw_is_parent)
    # Sub-configuration (try_compile probe): never re-run validation here;
    # only preserve the user's rules. A module-name value is not included:
    # probes run without CMAKE_MODULE_PATH and could not resolve it.
    if(z_vcpkg_mingw_user_override_@LANG@ AND EXISTS "${z_vcpkg_mingw_user_override_@LANG@}")
        include("${z_vcpkg_mingw_user_override_@LANG@}")
    endif()
    return()
endif()
if(z_vcpkg_mingw_@LANG@_deferred_error)
    include("${CMAKE_BINARY_DIR}/z_vcpkg_mingw_common.cmake")
    z_vcpkg_mingw_cleanup_determine_owned()
    string(REPLACE "\\n" "\n" z_vcpkg_mingw_@LANG@_deferred_error_text "${z_vcpkg_mingw_@LANG@_deferred_error}")
    message(FATAL_ERROR "${z_vcpkg_mingw_@LANG@_deferred_error_text}")
endif()
if(CMAKE_@LANG@_COMPILER AND NOT z_vcpkg_mingw_@LANG@_validated)
    include("${CMAKE_BINARY_DIR}/z_vcpkg_mingw_common.cmake")
    z_vcpkg_mingw_validate(@LANG@ "${CMAKE_@LANG@_COMPILER}")
    # The compiler was selected by CMake's own default search; remember that
    # so the next configure revalidates it (and may replace it), instead of
    # mistaking it for a user choice.
    set(z_vcpkg_mingw_@LANG@_determine_compiler "${CMAKE_@LANG@_COMPILER}" CACHE INTERNAL "")
endif()
if(z_vcpkg_mingw_user_override_@LANG@)
    include("${z_vcpkg_mingw_user_override_@LANG@}")
endif()
]===])
            string(REPLACE "@LANG@" "${z_mw_lang}" z_mw_wrapper_text "${z_mw_wrapper_text}")
            file(WRITE "${z_mw_wrapper}" "${z_mw_wrapper_text}")
            set(CMAKE_USER_MAKE_RULES_OVERRIDE_${z_mw_lang} "${z_mw_wrapper}" CACHE FILEPATH "" FORCE)
            set(CMAKE_USER_MAKE_RULES_OVERRIDE_${z_mw_lang} "${z_mw_wrapper}")
            set(z_vcpkg_mingw_${z_mw_lang}_override_marker "${z_mw_wrapper}" CACHE INTERNAL "")
            # Whatever CMake's own default search determines while no
            # CMAKE_<LANG>_COMPILER was present is owned by CMake, not by the
            # user, and may be replaced after a failure.
            if(NOT CMAKE_${z_mw_lang}_COMPILER)
                set(z_vcpkg_mingw_${z_mw_lang}_determine_owns 1 CACHE INTERNAL "")
            endif()
        else()
            # No wrapper needed. Remove a stale registration from an earlier
            # run, but never touch a value the user provided.
            if("${CMAKE_USER_MAKE_RULES_OVERRIDE_${z_mw_lang}}" STREQUAL "${z_vcpkg_mingw_${z_mw_lang}_override_marker}")
                unset(CMAKE_USER_MAKE_RULES_OVERRIDE_${z_mw_lang} CACHE)
                unset(z_vcpkg_mingw_${z_mw_lang}_override_marker CACHE)
                unset(z_vcpkg_mingw_${z_mw_lang}_determine_owns CACHE)
            endif()
        endif()
    endforeach()
endif()

# Resource compiler: architecture-prefixed windres first, then unprefixed.
set(z_mw_windres_names "")
foreach(z_mw_prefix IN LISTS z_vcpkg_mingw_prefixes)
    list(APPEND z_mw_windres_names "${z_mw_prefix}-windres")
endforeach()
find_program(CMAKE_RC_COMPILER NAMES ${z_mw_windres_names})
if(NOT CMAKE_RC_COMPILER)
    find_program(CMAKE_RC_COMPILER "windres")
endif()

# Forward the user rule overrides into try_compile probes, but only the
# values that are now real files (a user file resolved above, or a wrapper
# generated above). This runs in parent and sub configurations, so nested
# probes (probes of probes) inherit the values as well. A value that stayed
# a module name is not forwarded by this toolchain: probes run with a
# different working directory and without CMAKE_MODULE_PATH and could not
# resolve it. CMake itself resolves module names at the language
# initialization point and rewrites the variable to the full file path,
# which is what probes then receive.
foreach(z_mw_forward_override
        CMAKE_USER_MAKE_RULES_OVERRIDE
        CMAKE_USER_MAKE_RULES_OVERRIDE_C
        CMAKE_USER_MAKE_RULES_OVERRIDE_CXX)
    if(${z_mw_forward_override} AND EXISTS "${${z_mw_forward_override}}")
        list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ${z_mw_forward_override})
    endif()
endforeach()
list(REMOVE_DUPLICATES CMAKE_TRY_COMPILE_PLATFORM_VARIABLES)
