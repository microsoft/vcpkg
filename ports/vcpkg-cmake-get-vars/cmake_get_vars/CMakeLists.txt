cmake_minimum_required(VERSION 3.20)

if(NOT VCPKG_OUTPUT_FILE)
    message(FATAL_ERROR "VCPKG_OUTPUT_FILE is required to be defined")
endif()

if(NOT CMAKE_BUILD_TYPE)
    message(FATAL_ERROR "CMAKE_BUILD_TYPE is required to be defined")
else()
    string(TOUPPER "${CMAKE_BUILD_TYPE}" VCPKG_CONFIGS)
endif()

set(VCPKG_LANGUAGES "C;CXX" CACHE STRING "Languages to enables for this project")

project(get_cmake_vars LANGUAGES ${VCPKG_LANGUAGES})


set(OUTPUT_STRING "# Generator: ${CMAKE_CURRENT_LIST_FILE}\n")

function(escaped out_var value)
    string(REPLACE "\\" "\\\\" value "${value}")
    string(REPLACE "\"" "\\\"" value "${value}")
    string(REPLACE "\$" "\\\$" value "${value}")
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Build default checklists
list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_CROSSCOMPILING
                                        CMAKE_SYSTEM_NAME
                                        CMAKE_SYSTEM_VERSION
                                        CMAKE_HOST_SYSTEM_NAME
                                        CMAKE_SYSTEM_PROCESSOR
                                        CMAKE_HOST_SYSTEM_PROCESSOR
                                        CMAKE_SIZEOF_VOID_P
                                        CMAKE_LIBRARY_PATH_FLAG
                                        MSVC
                                        MSVC_VERSION)
if(ANDROID)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK
        CMAKE_ANDROID_ARCH
        CMAKE_ANDROID_ARCH_ABI
        CMAKE_ANDROID_ARM_MODE
        CMAKE_ANDROID_ARM_NEON
        CMAKE_ANDROID_NDK
        CMAKE_ANDROID_NDK_TOOLCHAIN_HOST_TAG
        CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION
        CMAKE_ANDROID_NDK_VERSION
        CMAKE_ANDROID_STL_TYPE
    )
    # Forward legacy variables from older NDKs
    if("${CMAKE_ANDROID_ARCH}" STREQUAL "")
        set(CMAKE_ANDROID_ARCH "${ANDROID_ARCH_NAME}")
    endif()
    if("${CMAKE_ANDROID_NDK_TOOLCHAIN_HOST_TAG}" STREQUAL "")
        set(CMAKE_ANDROID_NDK_TOOLCHAIN_HOST_TAG "${ANDROID_HOST_TAG}")
    endif()
    if(CMAKE_SYSTEM_VERSION STREQUAL "1" AND ANDROID_PLATFORM_LEVEL GREATER "1")
        set(CMAKE_SYSTEM_VERSION "${ANDROID_PLATFORM_LEVEL}")
    endif()
endif()
if(APPLE)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_OSX_DEPLOYMENT_TARGET
                                            CMAKE_OSX_SYSROOT)
endif()
# Programs to check
set(PROGLIST AR DLLTOOL LINKER MT NM OBJCOPY OBJDUMP RANLIB STRIP)
foreach(prog IN LISTS PROGLIST)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog})
endforeach()
set(COMPILERS ${VCPKG_LANGUAGES} RC)
foreach(prog IN LISTS COMPILERS)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog}_COMPILER)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog}_COMPILER_ID)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog}_COMPILER_VERSION)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog}_COMPILER_FRONTEND_VARIANT)
endforeach()
# Variables to check
foreach(_lang IN LISTS VCPKG_LANGUAGES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_STANDARD_INCLUDE_DIRECTORIES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_STANDARD_LIBRARIES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_STANDARD)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_COMPILE_FEATURES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_EXTENSION)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_COMPILER_TARGET)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_IMPLICIT_INCLUDE_DIRECTORIES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_IMPLICIT_LINK_DIRECTORIES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_IMPLICIT_LINK_LIBRARIES)
endforeach()
list(REMOVE_DUPLICATES VCPKG_DEFAULT_VARS_TO_CHECK)

# Environment variables to check. 
list(APPEND VCPKG_DEFAULT_ENV_VARS_TO_CHECK PATH INCLUDE C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)
list(REMOVE_DUPLICATES VCPKG_DEFAULT_ENV_VARS_TO_CHECK)

#Flags to check. Flags are a bit special since they are configuration aware. 
set(FLAGS ${VCPKG_LANGUAGES} RC SHARED_LINKER STATIC_LINKER EXE_LINKER)
foreach(flag IN LISTS FLAGS)
    list(APPEND VCPKG_DEFAULT_FLAGS_TO_CHECK CMAKE_${flag}_FLAGS)
endforeach()
list(REMOVE_DUPLICATES VCPKG_DEFAULT_FLAGS_TO_CHECK)

#Language-specific flags.
foreach(_lang IN LISTS VCPKG_LANGUAGES)
    list(APPEND VCPKG_LANG_FLAGS CMAKE_${_lang}_FLAGS)
endforeach()
list(REMOVE_DUPLICATES VCPKG_LANG_FLAGS)

# TODO if ever necessary: Properties to check

set(VCPKG_VAR_PREFIX "VCPKG_DETECTED" CACHE STRING "Variable prefix to use for detected flags")
set(VCPKG_VARS_TO_CHECK "${VCPKG_DEFAULT_VARS_TO_CHECK}" CACHE STRING "Variables to check. If not given there is a list of defaults")
set(VCPKG_FLAGS_TO_CHECK "${VCPKG_DEFAULT_FLAGS_TO_CHECK}" CACHE STRING "Variables to check. If not given there is a list of defaults")
set(VCPKG_ENV_VARS_TO_CHECK "${VCPKG_DEFAULT_ENV_VARS_TO_CHECK}" CACHE STRING "Variables to check. If not given there is a list of defaults")

foreach(VAR IN LISTS VCPKG_VARS_TO_CHECK VCPKG_FLAGS_TO_CHECK)
    escaped(value "${${VAR}}")
    string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${VAR} \"${value}\")\n")
endforeach()

foreach(_env IN LISTS VCPKG_ENV_VARS_TO_CHECK)
    if(CMAKE_HOST_WIN32)
        string(REPLACE "\\" "/" value "$ENV{${_env}}")
        escaped(value "${value}")
    else()
        escaped(value "$ENV{${_env}}")
    endif()
    string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_ENV_${_env} \"${value}\")\n")
endforeach()

set(EXTRA_FLAGS "")

if(APPLE)
    if(CMAKE_OSX_SYSROOT)
        string(APPEND EXTRA_FLAGS " -isysroot \"${CMAKE_OSX_SYSROOT}\"")
    endif()
    foreach(arch IN LISTS CMAKE_OSX_ARCHITECTURES)
        string(APPEND EXTRA_FLAGS " -arch ${arch}")
    endforeach()
    if(CMAKE_OSX_DEPLOYMENT_TARGET)
        list(GET VCPKG_LANGUAGES 0 lang)
        string(APPEND EXTRA_FLAGS " ${CMAKE_${lang}_OSX_DEPLOYMENT_TARGET_FLAG}${CMAKE_OSX_DEPLOYMENT_TARGET}")
        unset(lang)
    endif()
endif()
set(target_param "")
list(GET VCPKG_LANGUAGES 0 lang)
if(CMAKE_${lang}_COMPILER_TARGET)
    if (CMAKE_${lang}_COMPILER_ID STREQUAL Clang)
        set(target_param "${CMAKE_${lang}_COMPILE_OPTIONS_TARGET}${CMAKE_${lang}_COMPILER_TARGET}")
    elseif(CMAKE_${lang}_COMPILE_OPTIONS_TARGET)
        set(target_param "${CMAKE_${lang}_COMPILE_OPTIONS_TARGET} ${CMAKE_${lang}_COMPILER_TARGET}")
    endif()
endif()
if(CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        string(APPEND EXTRA_FLAGS " \"${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}\"")
    else()
        string(APPEND EXTRA_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN} \"${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}\"")
    endif()
endif()

set(extra_flags_compile "")
set(extra_flags_link "")
if(CMAKE_CXX_COMPILE_OPTIONS_SYSROOT)
    if(CMAKE_SYSROOT_COMPILE)
        string(APPEND extra_flags_compile " \"${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT_COMPILE}\"")
    elseif(CMAKE_SYSROOT)
        string(APPEND extra_flags_compile " \"${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}\"")
    endif()

    if(CMAKE_SYSROOT_LINK)
        string(APPEND extra_flags_link " \"${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT_LINK}\"")
    elseif(CMAKE_SYSROOT)
        string(APPEND extra_flags_link " \"${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}\"")
    endif()
endif()

set(flags_to_add_target_compile "${VCPKG_LANGUAGES}")
set(flags_to_add_target_link SHARED_LINKER EXE_LINKER STATIC_LINKER MODULE_LINKER)

foreach(flags IN LISTS flags_to_add_target_compile flags_to_add_target_link)
    set(${flags}_FLAGS "${target_param} ${CMAKE_${flags}_FLAGS} ${CMAKE_${flags}_FLAGS_${VCPKG_CONFIGS}} ${EXTRA_FLAGS}")
endforeach()

foreach(flags IN LISTS flags_to_add_target_compile)
    string(APPEND ${flags}_FLAGS " ${extra_flags_compile}")
    string(STRIP ${flags}_FLAGS "${${flags}_FLAGS}")
endforeach()

foreach(flags IN LISTS flags_to_add_target_link)
    string(APPEND ${flags}_FLAGS " ${extra_flags_link}")
    string(STRIP ${flags}_FLAGS "${${flags}_FLAGS}")
endforeach()

foreach(flags STATIC_LINKER RC)
    set(${flags}_FLAGS "${CMAKE_${flags}_FLAGS} ${CMAKE_${flags}_FLAGS_${VCPKG_CONFIGS}}")
    string(STRIP ${flags}_FLAGS "${${flags}_FLAGS}")
endforeach()

foreach(incdir IN LISTS CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES)
    string(APPEND CXX_FLAGS " \"${CMAKE_INCLUDE_FLAG_CXX}${incdir}\"")
endforeach()

foreach(incdir IN LISTS CMAKE_C_STANDARD_INCLUDE_DIRECTORIES)
    string(APPEND C_FLAGS " \"${CMAKE_INCLUDE_FLAG_C}${incdir}\"")
endforeach()

foreach(flag ${VCPKG_LANGUAGES} SHARED_LINKER EXE_LINKER STATIC_LINKER MODULE_LINKER RC)
    # When using MSVC, maybe transform /flags to -flags.
    #   When cross compiling, "/flags" may be an absolute path starting with /, so don't transform.
    #   Otherwise, transform to improve compatibility with scripts interpreting "/flags" as a path.
    if(MSVC AND "${CMAKE_HOST_SYSTEM_NAME}" MATCHES "Windows")
        # This implementation is imperfect because it fails on directories with trailing spaces,
        # but those are rare.
        string(REGEX REPLACE "(^| )/" "\\1-" ${flag}_FLAGS "${${flag}_FLAGS}")
        if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
            if("${flag}" STREQUAL "CXX")
                string(APPEND ${flag}_FLAGS " -ZW:nostdlib")
            endif()
        endif()
    endif()
    escaped(value "${${flag}_FLAGS}")
    string(APPEND OUTPUT_STRING "set(VCPKG_COMBINED_${flag}_FLAGS_${VCPKG_CONFIGS} \"${value}\")\n")
endforeach()

file(WRITE "${VCPKG_OUTPUT_FILE}" "${OUTPUT_STRING}")

# Programs:
# CMAKE_AR
# CMAKE_<LANG>_COMPILER_AR (Wrapper)
# CMAKE_RANLIB
# CMAKE_<LANG>_COMPILER_RANLIB
# CMAKE_STRIP
# CMAKE_NM
# CMAKE_OBJDUMP
# CMAKE_DLLTOOL
# CMAKE_MT
# CMAKE_LINKER
# CMAKE_C_COMPILER
# CMAKE_CXX_COMPILER
# CMAKE_RC_COMPILER

# Program details:
# CMAKE_<LANG>_COMPILER_ID
# CMAKE_<LANG>_COMPILER_VERSION
# MSVC
# MSVC_VERSION

# Flags:
# CMAKE_<LANG>_FLAGS
# CMAKE_<LANG>_FLAGS_<CONFIG>
# CMAKE_RC_FLAGS
# CMAKE_SHARED_LINKER_FLAGS
# CMAKE_SHARED_LINKER_FLAGS_<CONFIG>
# CMAKE_STATIC_LINKER_FLAGS
# CMAKE_STATIC_LINKER_FLAGS_<CONFIG>
# CMAKE_EXE_LINKER_FLAGS
# CMAKE_EXE_LINKER_FLAGS_<CONFIG>

# Additional information:
# CMAKE_SIZEOF_VOID_P
# CMAKE_CROSSCOMPILING
# CMAKE_SYSTEM_NAME
# CMAKE_HOST_SYSTEM_NAME
# CMAKE_SYSTEM_PROCESSOR
# CMAKE_HOST_SYSTEM_PROCESSOR
