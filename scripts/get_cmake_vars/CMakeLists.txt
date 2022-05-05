cmake_minimum_required(VERSION 3.20)

set(VCPKG_LANGUAGES "C;CXX" CACHE STRING "Languages to enables for this project")

set(OUTPUT_STRING)
# Build default checklists
list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_CROSSCOMPILING
                                        CMAKE_SYSTEM_NAME
                                        CMAKE_HOST_SYSTEM_NAME
                                        CMAKE_SYSTEM_PROCESSOR
                                        CMAKE_HOST_SYSTEM_PROCESSOR)
if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
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
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog}_COMPILER CMAKE_${prog}_COMPILER_ID)
endforeach()
# Variables to check
foreach(_lang IN LISTS VCPKG_LANGUAGES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_STANDARD_INCLUDE_DIRECTORIES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_STANDARD_LIBRARIES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_STANDARD)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_COMPILE_FEATURES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_EXTENSION)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
    
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

foreach(VAR IN LISTS VCPKG_VARS_TO_CHECK)
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

macro(_vcpkg_adjust_flags flag_var)
    if(MSVC) # Transform MSVC /flags to -flags due to bash scripts intepreting /flag as a path.
        string(REGEX REPLACE "(^| )/" "\\1-" ${flag_var} "${${flag_var}}")
        if(CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
            if("${flag_var}" STREQUAL "CMAKE_CXX_FLAGS")
                string(APPEND ${flag_var} " -ZW:nostdlib")
            endif()
        endif()
    endif()
    if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
        if("${flag_var}" IN_LIST VCPKG_LANG_FLAGS)
            # macOS - append arch and isysroot if cross-compiling
            if(NOT "${CMAKE_OSX_ARCHITECTURES}" STREQUAL "${CMAKE_HOST_SYSTEM_PROCESSOR}")
                foreach(arch IN LISTS CMAKE_OSX_ARCHITECTURES)
                    string(APPEND ${flag_var} " -arch ${arch}")
                endforeach()
            endif()
            string(APPEND ${flag_var} " -isysroot ${CMAKE_OSX_SYSROOT}")
            if (CMAKE_OSX_DEPLOYMENT_TARGET)
                string(APPEND ${flag_var} " -mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}") 
            endif()
        endif()
    endif()
endmacro()

foreach(flag IN LISTS VCPKG_FLAGS_TO_CHECK)
    string(STRIP "${${flag}}" ${flag}) # Strip leading and trailing whitespaces
    _vcpkg_adjust_flags(${flag})
    string(REPLACE [[\\]] [[\]] ${flag} "${${flag}}")
    string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_RAW_${flag} \" ${${flag}}\")\n")
    foreach(config IN LISTS VCPKG_CONFIGS)
        string(STRIP "${${flag}_${config}}" ${flag}_${config})
        _vcpkg_adjust_flags(${flag}_${config})
        string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_RAW_${flag}_${config} \"${CMAKE_${flag}_FLAGS_${config}}\")\n")
        set(COMBINED_${flag}_${config} "${${flag}} ${${flag}_${config}}")
        string(STRIP "${COMBINED_${flag}_${config}}" COMBINED_${flag}_${config})
        string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${flag}_${config} \"${COMBINED_${flag}_${config}}\")\n")
    endforeach()
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

# Flags:
# CMAKE_<LANG>_FLAGS
# CMAKE_<LANG>_FLAGS_<CONFIG>
# CMAKE_RC_FLAGS
# CMAKE_SHARED_LINKER_FLAGS
# CMAKE_STATIC_LINKER_FLAGS
# CMAKE_STATIC_LINKER_FLAGS_<CONFIG>
# CMAKE_EXE_LINKER_FLAGS
# CMAKE_EXE_LINKER_FLAGS_<CONFIG>
