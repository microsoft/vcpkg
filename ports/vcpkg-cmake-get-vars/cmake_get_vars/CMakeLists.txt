cmake_minimum_required(VERSION 3.20)

set(VCPKG_LANGUAGES "C;CXX" CACHE STRING "Languages to enables for this project")

set(OUTPUT_STRING)
# Build default checklists
list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_CROSSCOMPILING
                                        CMAKE_SYSTEM_NAME
                                        CMAKE_HOST_SYSTEM_NAME
                                        CMAKE_SYSTEM_PROCESSOR
                                        CMAKE_HOST_SYSTEM_PROCESSOR
                                        CMAKE_SIZEOF_VOID_P
                                        MSVC
                                        MSVC_VERSION)
if(APPLE)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_OSX_DEPLOYMENT_TARGET
                                            CMAKE_OSX_SYSROOT)
endif()
# Programs to check
set(PROGLIST AR RANLIB STRIP NM OBJDUMP DLLTOOL MT LINKER)
foreach(prog IN LISTS PROGLIST)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog})
endforeach()
set(COMPILERS ${VCPKG_LANGUAGES} RC)
foreach(prog IN LISTS COMPILERS)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog}_COMPILER)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog}_COMPILER_ID)
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
    # Probably never required since implicit.
    #list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
    #list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_IMPLICIT_INCLUDE_DIRECTORIES)
    #list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_IMPLICIT_LINK_DIRECTORIES)
    #list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_IMPLICIT_LINK_LIBRARIES)
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

if(NOT VCPKG_OUTPUT_FILE)
    message(FATAL_ERROR "VCPKG_OUTPUT_FILE is required to be defined")
endif()

if(NOT CMAKE_BUILD_TYPE)
    message(FATAL_ERROR "CMAKE_BUILD_TYPE is required to be defined")
else()
    string(TOUPPER "${CMAKE_BUILD_TYPE}" VCPKG_CONFIGS)
endif()


project(get_cmake_vars LANGUAGES ${VCPKG_LANGUAGES})

foreach(VAR IN LISTS VCPKG_VARS_TO_CHECK VCPKG_FLAGS_TO_CHECK)
  string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${VAR} \"${${VAR}}\")\n")
endforeach()

foreach(_env IN LISTS VCPKG_ENV_VARS_TO_CHECK)
    if(CMAKE_HOST_WIN32)
        string(REPLACE "\\" "/" ENV_${_env} "$ENV{${_env}}")
        string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_ENV_${_env} \"${ENV_${_env}}\")\n")
    else()
        string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_ENV_${_env} \"$ENV{${_env}}\")\n")
    endif()
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
if(CMAKE_SYSROOT AND CMAKE_CXX_COMPILE_OPTIONS_SYSROOT)
    string(APPEND EXTRA_FLAGS " \"${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}\"")
endif()

foreach(flags ${VCPKG_LANGUAGES} SHARED_LINKER EXE_LINKER STATIC_LINKER MODULE_LINKER)
    set(${flags}_FLAGS "${target_param} ${CMAKE_${flags}_FLAGS} ${CMAKE_${flags}_FLAGS_${VCPKG_CONFIGS}} ${EXTRA_FLAGS}")
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
    string(REPLACE "\\" "\\\\" ${flag}_FLAGS "${${flag}_FLAGS}")
    string(REPLACE "\"" "\\\"" ${flag}_FLAGS "${${flag}_FLAGS}")
    string(REPLACE "\$" "\\\$" ${flag}_FLAGS "${${flag}_FLAGS}")
    string(APPEND OUTPUT_STRING "set(VCPKG_COMBINED_${flag}_FLAGS_${VCPKG_CONFIGS} \"${${flag}_FLAGS}\")\n")
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
