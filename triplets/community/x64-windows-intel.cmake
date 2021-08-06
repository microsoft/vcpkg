function(z_vcpkg_load_environment_from_batch)
    cmake_parse_arguments(PARSE_ARGV 0 args "" "BATCH_FILE_PATH" "ARGUMENTS")
    if(args_BATCH_FILE_PATH STREQUAL "")
        message(FATAL_ERROR "'${CMAKE_CURRENT_FUNCTION}' requires argument BATCH_FILE_PATH")
    endif()

    # Get original environment
    execute_process(
        COMMAND "${CMAKE_COMMAND}" "-E" "environment"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        OUTPUT_FILE  "environment-initial-out.log"
        ERROR_FILE "environment-initial-err.log"
    )
    file(READ "${CURRENT_BUILDTREES_DIR}/environment-initial-out.log" ENVIRONMENT_INITIAL)

    # Get modified envirnoment
    string (REPLACE ";" " " SPACE_SEPARATED_ARGUMENTS "${args_ARGUMENTS}")
    #message(STATUS "args_BATCH_FILE_PATH:${args_BATCH_FILE_PATH}")
    file(WRITE "${CURRENT_BUILDTREES_DIR}/get-modified-environment.bat" "call \"${args_BATCH_FILE_PATH}\" ${SPACE_SEPARATED_ARGUMENTS}\n\"${CMAKE_COMMAND}\" -E environment")
    execute_process(
        COMMAND "cmd" "/c" "${CURRENT_BUILDTREES_DIR}/get-modified-environment.bat"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        OUTPUT_FILE  "environment-after-out.log"
        ERROR_FILE "environment-after-err.log"
    )
    file(READ "${CURRENT_BUILDTREES_DIR}/environment-after-out.log" ENVIRONMENT_AFTER)

    # Escape characters that have a special meaning in CMake strings.
    string(REPLACE "\\" "/"     ENVIRONMENT_INITIAL "${ENVIRONMENT_INITIAL}")
    string(REPLACE ";"  "\\\\;" ENVIRONMENT_INITIAL "${ENVIRONMENT_INITIAL}")
    string(REPLACE "\n" ";"     ENVIRONMENT_INITIAL "${ENVIRONMENT_INITIAL}")

    string(REPLACE "\\" "/"     ENVIRONMENT_AFTER "${ENVIRONMENT_AFTER}")
    string(REPLACE ";"  "\\\\;" ENVIRONMENT_AFTER "${ENVIRONMENT_AFTER}")
    string(REPLACE "\n" ";"     ENVIRONMENT_AFTER "${ENVIRONMENT_AFTER}")

    # Apply the environment changes to the current CMake environment
    foreach(AFTER_LINE IN LISTS ENVIRONMENT_AFTER)
        if("${AFTER_LINE}" MATCHES "^([^=]+)=(.+)$")
            set(AFTER_VAR_NAME "${CMAKE_MATCH_1}")
            set(AFTER_VAR_VALUE "${CMAKE_MATCH_2}")

            set(FOUND "FALSE")
            foreach(INITIAL_LINE IN LISTS ENVIRONMENT_INITIAL)
                if("${INITIAL_LINE}" MATCHES "^([^=]+)=(.+)$")
                    set(INITIAL_VAR_NAME "${CMAKE_MATCH_1}")
                    set(INITIAL_VAR_VALUE "${CMAKE_MATCH_2}")
                    
                    if("${AFTER_VAR_NAME}" STREQUAL "${INITIAL_VAR_NAME}")
                        set(FOUND "TRUE")
                        if(NOT "${AFTER_VAR_VALUE}" STREQUAL "${INITIAL_VAR_VALUE}")
                            
                            # Variable has been modified
                            # NOTE: we do not revert the escape changes that have previously been applied
                            #       since the only change that should be visible in a single environment variable
                            #       should be a conversion from `\` to `/` and this should not have any effect on
                            #       windows paths.
                            #message(STATUS "MODIFIED ${AFTER_VAR_NAME}=${AFTER_VAR_VALUE}")
                            set(ENV{${AFTER_VAR_NAME}} "${AFTER_VAR_VALUE}")
                        endif()
                    endif()
                endif()
            endforeach()

            if(NOT FOUND)
                # Variable has been added
                set(ENV{${AFTER_VAR_NAME}} "${AFTER_VAR_VALUE}")
            endif()
        endif()
    endforeach()
endfunction()

###################################################

#Toolset-Name: Intel(R) oneAPI DPC++ Compiler

set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_ENV_PASSTHROUGH_UNTRACKED "ONEAPI_ROOT;IFORT_COMPILER19;IFORT_COMPILER20;IFORT_COMPILER21")

if(NOT PORT MATCHES "(boost|hwloc)")
    set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/x64-windows-intel.toolchain.cmake")
    if(DEFINED VCPKG_PLATFORM_TOOLSET)
        set(VCPKG_PLATFORM_TOOLSET "Intel(R) oneAPI DPC++ Compiler")
    endif()
endif()

# if(NOT PORT MATCHES "(lapack)")
    # set(VCPKG_LIBRARY_LINKAGE static)
# endif()

#set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
#set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled)
set(VCPKG_LOAD_VCVARS_ENV ON)

include(vcpkg_execute_required_process OPTIONAL RESULT_VARIABLE ENV_LOADABLE) # Trick to skip the compiler detection for this file. 
if(ENV_LOADABLE)
    find_file(SETVARS NAMES setvars.bat PATHS ENV ONEAPI_ROOT)
    z_vcpkg_load_environment_from_batch(BATCH_FILE_PATH "${SETVARS}")
endif()