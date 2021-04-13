cmake_minimum_required(VERSION 3.17)

set(VCPKG_LANGUAGES "C;CXX" CACHE STRING "Languages to enables for this project")

set(OUTPUT_STRING)
# Build default checklists
list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_CROSSCOMPILING
                                        CMAKE_SYSTEM_NAME
                                        CMAKE_HOST_SYSTEM_NAME
                                        CMAKE_SYSTEM_PROCESSOR
                                        CMAKE_HOST_SYSTEM_PROCESSOR
                                        CMAKE_INCLUDE_FLAG_C
                                        CMAKE_INCLUDE_FLAG_CXX
                                        CMAKE_INCLUDE_FLAG_C_SEP
                                        CMAKE_INCLUDE_FLAG_CXX_SEP
)

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
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${prog}_COMPILER)
endforeach()
# Variables to check
foreach(_lang IN LISTS VCPKG_LANGUAGES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_STANDARD_INCLUDE_DIRECTORIES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_STANDARD_LIBRARIES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_STANDARD)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_COMPILE_FEATURES)
    list(APPEND VCPKG_DEFAULT_VARS_TO_CHECK CMAKE_${_lang}_EXTENSION)
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

if(APPLE)
 
    foreach(_arch ${CMAKE_OSX_ARCHITECTURES})
        string(APPEND CMAKE_CXX_FLAGS " -arch ${_arch}")
        string(APPEND CMAKE_C_FLAGS " -arch ${_arch}")
    endforeach()
 
    if(CMAKE_OSX_DEPLOYMENT_TARGET)
        string(APPEND CMAKE_CXX_FLAGS " ${CMAKE_CXX_OSX_DEPLOYMENT_TARGET_FLAG}${CMAKE_OSX_DEPLOYMENT_TARGET}")
        string(APPEND CMAKE_C_FLAGS " ${CMAKE_C_OSX_DEPLOYMENT_TARGET_FLAG}${CMAKE_OSX_DEPLOYMENT_TARGET}")
    endif()
 
    if(CMAKE_OSX_SYSROOT)
        string(APPEND CMAKE_CXX_FLAGS " ${CMAKE_CXX_SYSROOT_FLAG} ${CMAKE_OSX_SYSROOT}")
        string(APPEND CMAKE_C_FLAGS " ${CMAKE_C_SYSROOT_FLAG} ${CMAKE_OSX_SYSROOT}")
    endif()
 
else()
 
    if(CMAKE_CXX_COMPILER_TARGET AND CMAKE_CXX_COMPILE_OPTIONS_TARGET)
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            string(APPEND CMAKE_CXX_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_TARGET}${CMAKE_CXX_COMPILER_TARGET}")
            string(APPEND CMAKE_C_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_TARGET}${CMAKE_CXX_COMPILER_TARGET}")
            string(APPEND CMAKE_STATIC_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_TARGET}${CMAKE_CXX_COMPILER_TARGET}")
            string(APPEND CMAKE_SHARED_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_TARGET}${CMAKE_CXX_COMPILER_TARGET}")
        else()
            string(APPEND CMAKE_CXX_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_TARGET} ${CMAKE_CXX_COMPILER_TARGET}")
            string(APPEND CMAKE_C_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_TARGET} ${CMAKE_CXX_COMPILER_TARGET}")
            string(APPEND CMAKE_STATIC_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_TARGET} ${CMAKE_CXX_COMPILER_TARGET}")
            string(APPEND CMAKE_SHARED_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_TARGET} ${CMAKE_CXX_COMPILER_TARGET}")
        endif()
    endif()
 
    if(CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN AND CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN)
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            string(APPEND CMAKE_CXX_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
            string(APPEND CMAKE_C_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
            string(APPEND CMAKE_STATIC_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
            string(APPEND CMAKE_SHARED_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN}${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
        else()
            string(APPEND CMAKE_CXX_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN} ${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
            string(APPEND CMAKE_C_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN} ${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
            string(APPEND CMAKE_STATIC_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN} ${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
            string(APPEND CMAKE_SHARED_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_EXTERNAL_TOOLCHAIN} ${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
        endif()
    endif()
 
    if(CMAKE_SYSROOT AND CMAKE_CXX_COMPILE_OPTIONS_SYSROOT)
        string(APPEND CMAKE_CXX_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}")
        string(APPEND CMAKE_C_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}")
        string(APPEND CMAKE_STATIC_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS " ${CMAKE_CXX_COMPILE_OPTIONS_SYSROOT}${CMAKE_SYSROOT}")
    endif()
 
endif()
 
foreach(_lang IN ITEMS C CXX)
    foreach(INCDIR ${CMAKE_${_lang}_IMPLICIT_INCLUDE_DIRECTORIES})
        string(APPEND CMAKE_${_lang}_FLAGS " ${CMAKE_INCLUDE_SYSTEM_FLAG_${_lang}}${INCDIR}")
    endforeach()
    foreach(INCDIR ${CMAKE_${_lang}_STANDARD_INCLUDE_DIRECTORIES})
        string(APPEND CMAKE_${_lang}_FLAGS " ${CMAKE_INCLUDE_FLAG_${_lang}}${CMAKE_INCLUDE_FLAG_${_lang}_SEP}${INCDIR}")
    endforeach()
endforeach()

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
    endif()
endmacro()

foreach(flag IN LISTS VCPKG_FLAGS_TO_CHECK)
    string(STRIP "${${flag}}" ${flag}) # Strip leading and trailing whitespaces
    _vcpkg_adjust_flags(${flag})
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
