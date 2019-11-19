function(vcpkg_load_environment_from_batch)
    cmake_parse_arguments(_lefb "" "BATCH_FILE_PATH" "ARGUMENTS" ${ARGN})

    message(STATUS "LOADING ENV")
    # Get original environment
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" "-E" "environment"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
        LOGNAME environment-initial
    )
    file(READ ${CURRENT_BUILDTREES_DIR}/environment-initial-out.log ENVIRONMENT_INITIAL)

    # Get modified envirnoment
    string (REPLACE ";" " " SPACE_SEPARATED_ARGUMENTS "${_lefb_ARGUMENTS}")
    file(WRITE ${CURRENT_BUILDTREES_DIR}/get-modified-environment.bat "call \"${_lefb_BATCH_FILE_PATH}\" ${SPACE_SEPARATED_ARGUMENTS}\n\"${CMAKE_COMMAND}\" -E environment")
    vcpkg_execute_required_process(
        COMMAND "cmd" "/c" "${CURRENT_BUILDTREES_DIR}/get-modified-environment.bat"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
        LOGNAME environment-after
    )
    file(READ ${CURRENT_BUILDTREES_DIR}/environment-after-out.log ENVIRONMENT_AFTER)
    
    # Escape characters that have a special meaning in CMake strings.
    string(REPLACE "\\" "/"     ENVIRONMENT_INITIAL "${ENVIRONMENT_INITIAL}")
    string(REPLACE ";"  "\\\\;" ENVIRONMENT_INITIAL "${ENVIRONMENT_INITIAL}")
    string(REPLACE "\n" ";"     ENVIRONMENT_INITIAL "${ENVIRONMENT_INITIAL}")

    string(REPLACE "\\" "/"     ENVIRONMENT_AFTER "${ENVIRONMENT_AFTER}")
    string(REPLACE ";"  "\\\\;" ENVIRONMENT_AFTER "${ENVIRONMENT_AFTER}")
    string(REPLACE "\n" ";"     ENVIRONMENT_AFTER "${ENVIRONMENT_AFTER}")

    # Apply the environment changes to the current CMake environment
    foreach(AFTER_LINE ${ENVIRONMENT_AFTER})
        if("${AFTER_LINE}" MATCHES "^([^=]+)=(.+)$")
            set(AFTER_VAR_NAME "${CMAKE_MATCH_1}")
            set(AFTER_VAR_VALUE "${CMAKE_MATCH_2}")

            set(FOUND "FALSE")
            foreach(INITIAL_LINE ${ENVIRONMENT_INITIAL})
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
                            set(ENV{${AFTER_VAR_NAME}} ${AFTER_VAR_VALUE})
                        endif()
                    endif()
                endif()
            endforeach()

            if(NOT ${FOUND})
                # Variable has been added
                message(STATUS "ADDING ${AFTER_VAR_NAME}=${AFTER_VAR_VALUE}")
                set(ENV{${AFTER_VAR_NAME}} ${AFTER_VAR_VALUE})
            endif()
        endif()
    endforeach()
endfunction()