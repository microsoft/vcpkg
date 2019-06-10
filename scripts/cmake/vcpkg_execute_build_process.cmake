# Usage: vcpkg_execute_build_process(COMMAND <cmd> [<args>...] [NO_PARALLEL_COMMAND <cmd> [<args>...]]
#                                    WORKING_DIRECTORY </path/to/dir> LOGNAME <log_name>)
function(vcpkg_execute_build_process)
    cmake_parse_arguments(_ebp "" "WORKING_DIRECTORY;LOGNAME" "COMMAND;NO_PARALLEL_COMMAND" ${ARGN})

    set(LOG_OUT "${CURRENT_BUILDTREES_DIR}/${_ebp_LOGNAME}-out.log")
    set(LOG_ERR "${CURRENT_BUILDTREES_DIR}/${_ebp_LOGNAME}-err.log")

    execute_process(
        COMMAND ${_ebp_COMMAND}
        WORKING_DIRECTORY ${_ebp_WORKING_DIRECTORY}
        OUTPUT_FILE ${LOG_OUT}
        ERROR_FILE ${LOG_ERR}
        RESULT_VARIABLE error_code
    )

    if(error_code)
        file(READ ${LOG_OUT} out_contents)
        file(READ ${LOG_ERR} err_contents)

        if(out_contents)
            list(APPEND LOGS ${LOG_OUT})
        endif()
        if(err_contents)
            list(APPEND LOGS ${LOG_ERR})
        endif()

        if(_ebp_NO_PARALLEL_COMMAND AND
           (out_contents MATCHES "LINK : fatal error LNK1102:" OR out_contents MATCHES " fatal error C1060: "
           OR err_contents MATCHES "LINK : fatal error LNK1102:" OR err_contents MATCHES " fatal error C1060: "))
            # The linker ran out of memory during execution. We will try continuing once more, with parallelism disabled.
            message(STATUS "Restarting Build without parallelism because memory exceeded")
            set(LOG_OUT "${CURRENT_BUILDTREES_DIR}/${_ebp_LOGNAME}-out-1.log")
            set(LOG_ERR "${CURRENT_BUILDTREES_DIR}/${_ebp_LOGNAME}-err-1.log")
            execute_process(
                COMMAND ${_ebp_NO_PARALLEL_COMMAND}
                WORKING_DIRECTORY ${_ebp_WORKING_DIRECTORY}
                OUTPUT_FILE ${LOG_OUT}
                ERROR_FILE ${LOG_ERR}
                RESULT_VARIABLE error_code
            )

            if(error_code)
                file(READ ${LOG_OUT} out_contents)
                file(READ ${LOG_ERR} err_contents)

                if(out_contents)
                    list(APPEND LOGS ${LOG_OUT})
                endif()
                if(err_contents)
                    list(APPEND LOGS ${LOG_ERR})
                endif()
            endif()
        endif()

        if(error_code)
            set(STRINGIFIED_LOGS)
            foreach(LOG ${LOGS})
                file(TO_NATIVE_PATH "${LOG}" NATIVE_LOG)
                list(APPEND STRINGIFIED_LOGS "    ${NATIVE_LOG}\n")
            endforeach()
            message(FATAL_ERROR
                "  Command failed: ${_ebp_COMMAND}\n"
                "  Working Directory: ${_ebp_WORKING_DIRECTORY}\n"
                "  See logs for more information:\n"
                ${STRINGIFIED_LOGS})
        endif(error_code)
    endif(error_code)
endfunction(vcpkg_execute_build_process)
