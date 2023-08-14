include_guard(GLOBAL)

function(x_vcpkg_pkgconfig_get_modules)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "CFLAGS;LIBS;LIBRARIES;LIBRARIES_DIR;INCLUDE_DIRS;USE_MSVC_SYNTAX_ON_WINDOWS" "PREFIX" "MODULES")
    if(NOT DEFINED arg_PREFIX OR arg_PREFIX STREQUAL "")
        message(FATAL_ERROR "x_vcpkg_pkgconfig_get_modules requires parameter PREFIX!")
    endif()
    if(NOT DEFINED arg_MODULES OR arg_MODULES STREQUAL "")
        message(FATAL_ERROR "x_vcpkg_pkgconfig_get_modules requires parameter MODULES!")
    endif()
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "extra arguments passed to x_vcpkg_pkgconfig_get_modules: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    set(msvc "")
    if(arg_USE_MSVC_SYNTAX_ON_WINDOWS AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        set(msvc "--msvc-syntax")
    endif()

    set(PKGCONFIG "${CURRENT_INSTALLED_DIR}/../@HOST_TRIPLET@/tools/pkgconf/pkgconf@VCPKG_HOST_EXECUTABLE_SUFFIX@")

    set(backup_PKG_CONFIG_PATH "$ENV{PKG_CONFIG_PATH}")

    set(var_suffixes)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_set_pkgconfig_path("${CURRENT_INSTALLED_DIR}/lib/pkgconfig${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${backup_PKG_CONFIG_PATH}")
        if(arg_LIBS)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --libs ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_LIBS_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes LIBS_RELEASE)
        endif()
        if(arg_LIBRARIES)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --libs-only-l ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_LIBRARIES_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes LIBRARIES_RELEASE)
        endif()
        if(arg_LIBRARIES_DIRS)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --libs-only-L ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_LIBRARIES_DIRS_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes LIBRARIES_DIRS_RELEASE)
        endif()
        if(arg_INCLUDE_DIRS)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --cflags-only-I ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_INCLUDE_DIRS_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes INCLUDE_DIRS_RELEASE)
        endif()
        if(arg_CFLAGS)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --cflags ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_CFLAGS_RELEASE
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes CFLAGS_RELEASE)
        endif()
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_set_pkgconfig_path("${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig" "${backup_PKG_CONFIG_PATH}")
        if(arg_LIBS)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --libs ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_LIBS_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes LIBS_DEBUG)
        endif()
        if(arg_LIBRARIES)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --libs-only-l ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_LIBRARIES_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes LIBRARIES_DEBUG)
        endif()
        if(arg_LIBRARIES_DIRS)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --libs-only-L ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_LIBRARIES_DIRS_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes LIBRARIES_DIRS_DEBUG)
        endif()
        if(arg_INCLUDE_DIRS)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --cflags-only-I ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_INCLUDE_DIRS_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes INCLUDE_DIRS_DEBUG)
        endif()
        if(arg_CFLAGS)
            execute_process(
                COMMAND "${PKGCONFIG}" ${msvc} --cflags ${arg_MODULES}
                OUTPUT_VARIABLE ${arg_PREFIX}_CFLAGS_DEBUG
                OUTPUT_STRIP_TRAILING_WHITESPACE
                COMMAND_ERROR_IS_FATAL ANY
            )
            list(APPEND var_suffixes CFLAGS_DEBUG)
        endif()
    endif()
    set(ENV{PKG_CONFIG_PATH} "${backup_PKG_CONFIG_PATH}")

    foreach(_var IN LISTS var_suffixes)
        set("${arg_PREFIX}_${_var}" "${${arg_PREFIX}_${_var}}" PARENT_SCOPE)
    endforeach()
endfunction()

function(z_vcpkg_set_pkgconfig_path _path _backup)
    if(NOT _backup STREQUAL "")
        set(ENV{PKG_CONFIG_PATH} "${_path}${VCPKG_HOST_PATH_SEPARATOR}${_backup}")
    else()
        set(ENV{PKG_CONFIG_PATH} "${_path}")
    endif()
endfunction()
