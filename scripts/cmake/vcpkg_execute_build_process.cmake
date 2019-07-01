## # vcpkg_execute_build_process
##
## Execute a required build process
##
## ## Usage
## ```cmake
## vcpkg_execute_build_process(
##     COMMAND <cmd> [<args>...]
##     [NO_PARALLEL_COMMAND <cmd> [<args>...]]
##     WORKING_DIRECTORY </path/to/dir>
##     LOGNAME <log_name>)
## )
## ```
## ## Parameters
## ### COMMAND
## The command to be executed, along with its arguments.
##
## ### NO_PARALLEL_COMMAND
## Optional parameter which specifies a non-parallel command to attempt if a
## failure potentially due to parallelism is detected.
##
## ### WORKING_DIRECTORY
## The directory to execute the command in.
##
## ### LOGNAME
## The prefix to use for the log files.
##
## This should be a unique name for different triplets so that the logs don't
## conflict when building multiple at once.
##
## ## Examples
##
## * [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)
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

        if(out_contents MATCHES "LINK : fatal error LNK1102:" OR out_contents MATCHES " fatal error C1060: "
           OR err_contents MATCHES "LINK : fatal error LNK1102:" OR err_contents MATCHES " fatal error C1060: "
           OR out_contents MATCHES "LINK : fatal error LNK1318: Unexpected PDB error; ACCESS_DENIED"
           OR out_contents MATCHES "LINK : fatal error LNK1104:"
           OR out_contents MATCHES "LINK : fatal error LNK1201:")
            # The linker ran out of memory during execution. We will try continuing once more, with parallelism disabled.
            message(STATUS "Restarting Build without parallelism because memory exceeded")
            set(LOG_OUT "${CURRENT_BUILDTREES_DIR}/${_ebp_LOGNAME}-out-1.log")
            set(LOG_ERR "${CURRENT_BUILDTREES_DIR}/${_ebp_LOGNAME}-err-1.log")

            if(_ebp_NO_PARALLEL_COMMAND)
                execute_process(
                    COMMAND ${_ebp_NO_PARALLEL_COMMAND}
                    WORKING_DIRECTORY ${_ebp_WORKING_DIRECTORY}
                    OUTPUT_FILE ${LOG_OUT}
                    ERROR_FILE ${LOG_ERR}
                    RESULT_VARIABLE error_code
                )
            else()
                execute_process(
                    COMMAND ${_ebp_COMMAND}
                    WORKING_DIRECTORY ${_ebp_WORKING_DIRECTORY}
                    OUTPUT_FILE ${LOG_OUT}
                    ERROR_FILE ${LOG_ERR}
                    RESULT_VARIABLE error_code
                )
            endif()

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
        elseif(out_contents MATCHES "mt : general error c101008d: " OR out_contents MATCHES "mt.exe : general error c101008d: ")
            # Antivirus workaround - occasionally files are locked and cause mt.exe to fail
            message(STATUS "mt.exe has failed. This may be the result of anti-virus. Disabling anti-virus on the buildtree folder may improve build speed")
            set(ITERATION 0)
            while (ITERATION LESS 3 AND (out_contents MATCHES "mt : general error c101008d: " OR out_contents MATCHES "mt.exe : general error c101008d: "))
                MATH(EXPR ITERATION "${ITERATION}+1")
                message(STATUS "Restarting Build ${TARGET_TRIPLET}-${SHORT_BUILDTYPE} because of mt.exe file locking issue. Iteration: ${ITERATION}")
                execute_process(
                    COMMAND ${_ebp_COMMAND}
                    OUTPUT_FILE "${LOGPREFIX}-out-${ITERATION}.log"
                    ERROR_FILE "${LOGPREFIX}-err-${ITERATION}.log"
                    RESULT_VARIABLE error_code
                    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE})

                if(error_code)
                    file(READ "${LOGPREFIX}-out-${ITERATION}.log" out_contents)
                    file(READ "${LOGPREFIX}-err-${ITERATION}.log" err_contents)

                    if(out_contents)
                        list(APPEND LOGS "${LOGPREFIX}-out-${ITERATION}.log")
                    endif()
                    if(err_contents)
                        list(APPEND LOGS "${LOGPREFIX}-err-${ITERATION}.log")
                    endif()
                else()
                    break()
                endif()
            endwhile()
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
