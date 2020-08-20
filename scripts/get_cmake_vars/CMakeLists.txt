cmake_minimum_required(VERSION 3.17)

set(VCPKG_LANGUAGES "C;CXX" CACHE STRING "LANGUAGES TO ENABLE FOR THIS PROJECT")
set(VCPKG_VAR_PREFIX "VCPKG_DETECTED" CACHE STRING "Variable prefix to use for detected flags")
set(VCPKG_CONFIGS "DEBUG;RELEASE" CACHE STRING "Configurations to detect flags for")
set(VCPKG_OUTPUT_FILE "${CMAKE_BINARY_DIR}/../detected_flags.cmake.${VCPKG_TARGET_TRIPLET}.log" CACHE STRING "Output CMake files")
set(VCPKG_ADDITIONAL_OUTPUT_VARS "" CACHE STRING "Additional variables to output.")

set(OUTPUT_STRING)
project(get_cmake_vars LANGUAGES ${VCPKG_LANGUAGES})

if(MSVC)
    string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_MSVC TRUE)\n")
endif()
string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_CROSSCOMPILING ${CMAKE_CROSSCOMPILING})\n")
string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_SYSEM_NAME \"${CMAKE_SYSTEM_NAME}\")\n")
string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_SYSTEM_PROCESSOR \"${CMAKE_SYSTEM_PROCESSOR}\")\n")
# other:
# CMAKE_C_STANDARD
# CMAKE_CXX_STANDARD

set(PROGLIST AR RANLIB STRIP NM OBJDUMP DLLTOOL MT LINKER)
foreach(prog IN LISTS PROGLIST)
    string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${prog} \"${CMAKE_${prog}}\")\n")
endforeach()

set(COMPILERS ${VCPKG_LANGUAGES} RC)
foreach(prog IN LISTS COMPILERS)
    string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${prog}_COMPILER \"${CMAKE_${prog}_COMPILER}\")\n")
endforeach()

set(FLAGS ${VCPKG_LANGUAGES} RC SHARED_LINKER STATIC_LINKER EXE_LINKER)
foreach(flag IN LISTS FLAGS)
    string(REGEX REPLACE " +" " " CMAKE_${flag}_FLAGS "${CMAKE_${flag}_FLAGS}")
    string(REGEX REPLACE "( |^)/" "\\1-" CMAKE_${flag}_FLAGS "${CMAKE_${flag}_FLAGS}")
    string(STRIP "${CMAKE_${flag}_FLAGS}" CMAKE_${flag}_FLAGS)
    string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${flag}FLAGS \" ${CMAKE_${flag}_FLAGS}\")\n")
    foreach(config IN LISTS VCPKG_CONFIGS)
        string(REGEX REPLACE " +" " " CMAKE_${flag}_FLAGS_${config} "${CMAKE_${flag}_FLAGS_${config}}")
        string(REGEX REPLACE "( |^)/" "\\1-" CMAKE_${flag}_FLAGS_${config} "${CMAKE_${flag}_FLAGS_${config}}")
        string(STRIP "${CMAKE_${flag}_FLAGS_${config}}" CMAKE_${flag}_FLAGS_${config})
        string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${flag}FLAGS_${config} \"${CMAKE_${flag}_FLAGS_${config}}\")\n")
        set(COMBINED_${flag}_${config}_FLAGS "${CMAKE_${flag}_FLAGS} ${CMAKE_${flag}_FLAGS_${config}}")
        string(REGEX REPLACE " +" " " COMBINED_${flag}_${config}_FLAGS "${COMBINED_${flag}_${config}_FLAGS}")
        string(STRIP "${COMBINED_${flag}_${config}_FLAGS}" COMBINED_${flag}_${config}_FLAGS)
        string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_COMBINED_${flag}FLAGS_${config} \"${COMBINED_${flag}_${config}_FLAGS}\")\n")
    endforeach()
endforeach()

set(additional_vars)
foreach(_lang IN LISTS VCPKG_LANGUAGES)
    list(APPEND additional_vars CMAKE_${_lang}_STANDARD_INCLUDE_DIRECTORIES)
    list(APPEND additional_vars CMAKE_${_lang}_STANDARD_LIBRARIES)
    # Probably not required. 
    #list(APPEND additional_vars CMAKE_${_lang}_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES)
    #list(APPEND additional_vars CMAKE_${_lang}_IMPLICIT_INCLUDE_DIRECTORIES)
    #list(APPEND additional_vars CMAKE_${_lang}_IMPLICIT_LINK_DIRECTORIES)
    #list(APPEND additional_vars CMAKE_${_lang}_IMPLICIT_LINK_LIBRARIES)
endforeach()
# list(APPEND additional_vars CMAKE_LINK_INTERFACE_LIBRARIES) #deprecated

foreach(_var IN LISTS additional_vars)
    string(REPLACE "CMAKE_" "" outvar "${_var}")
    string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${outvar} \"${${_var}}\")\n")
endforeach()

# These seem to be empty.
# set(add_props INCLUDE_DIRECTORIES COMPILE_DEFINITIONS COMPILE_OPTIONS LINK_DIRECTORIES LINK_OPTIONS)
# foreach(prop IN LISTS add_props)
    # get_directory_property(${prop} ${prop})
    # string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${prop} ${${prop}})\n")
    # foreach(config IN LISTS VCPKG_CONFIGS)
        # get_directory_property(${prop}_${config} ${prop}_${config})
        # string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${prop}_${config} ${${prop}_${config}})\n")
    # endforeach()
# endforeach()
set(ENV_VARIABLES PATH INCLUDE C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH )
foreach(_env IN LISTS ENV_VARIABLES)
    IF(WIN32)
        string(REPLACE "\\" "/" ENV_${_env} "$ENV{${_env}}")
        string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_ENV_${_env} \"${ENV_${_env}}\")\n")
    else()
        string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_ENV_${_env} \"$ENV{${_env}}\")\n")
    endif()
endforeach()

foreach(addvar IN LISTS VCPKG_ADDITIONAL_OUTPUT_VARS)
    string(REPLACE "CMAKE_" outvar "${addvar}")
    string(APPEND OUTPUT_STRING "set(${VCPKG_VAR_PREFIX}_${outvar} \"${${addvar}}\")\n")
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
# CMAKE_RC_FLAGS

# Flags:
# CMAKE_<LANG>_FLAGS
# CMAKE_<LANG>_FLAGS_<CONFIG>
# CMAKE_SHARED_LINKER_FLAGS
# CMAKE_STATIC_LINKER_FLAGS
# CMAKE_STATIC_LINKER_FLAGS_<CONFIG>
# CMAKE_EXE_LINKER_FLAGS
# CMAKE_EXE_LINKER_FLAGS_<CONFIG>
