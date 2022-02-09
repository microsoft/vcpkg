#[===[.md:
# vcpkg_execute_build_process

Execute a required build process

## Usage
```cmake
vcpkg_execute_build_process(
    COMMAND <cmd> [<args>...]
    [NO_PARALLEL_COMMAND <cmd> [<args>...]]
    WORKING_DIRECTORY </path/to/dir>
    LOGNAME <log_name>
)
```
## Parameters
### COMMAND
The command to be executed, along with its arguments.

### NO_PARALLEL_COMMAND
Optional parameter which specifies a non-parallel command to attempt if a
failure potentially due to parallelism is detected.

### WORKING_DIRECTORY
The directory to execute the command in.

### LOGNAME
The prefix to use for the log files.

This should be a unique name for different triplets so that the logs don't
conflict when building multiple at once.

## Examples

* [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)
#]===]

set(Z_VCPKG_EXECUTE_BUILD_PROCESS_RETRY_ERROR_MESSAGES
    "LINK : fatal error LNK1102:"
    " fatal error C1060: "
    # The linker ran out of memory during execution. We will try continuing once more, with parallelism disabled.
    "LINK : fatal error LNK1318:"
    "LINK : fatal error LNK1104:"
    "LINK : fatal error LNK1201:"
    "ld terminated with signal 9"
    "Killed signal terminated program"
    # Multiple threads using the same directory at the same time cause conflicts, will try again.
    "Cannot create parent directory"
    "Cannot write file"
    # Multiple threads caused the wrong order of creating folders and creating files in folders
    "Can't open"
)
list(JOIN Z_VCPKG_EXECUTE_BUILD_PROCESS_RETRY_ERROR_MESSAGES "|" Z_VCPKG_EXECUTE_BUILD_PROCESS_RETRY_ERROR_MESSAGES)

function(vcpkg_execute_build_process)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "WORKING_DIRECTORY;LOGNAME" "COMMAND;NO_PARALLEL_COMMAND")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(required_arg IN ITEMS WORKING_DIRECTORY COMMAND)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "${required_arg} must be specified.")
        endif()
    endforeach()

    if(NOT DEFINED arg_LOGNAME)
        message(WARNING "LOGNAME should be specified.")
        set(arg_LOGNAME "build")
    endif()

    set(log_prefix "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}")
    set(log_out "${log_prefix}-out.log")
    set(log_err "${log_prefix}-err.log")
    set(all_logs "${log_out}" "${log_err}")

    execute_process(
        COMMAND ${arg_COMMAND}
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        OUTPUT_FILE "${log_out}"
        ERROR_FILE "${log_err}"
        RESULT_VARIABLE error_code
    )

    if(NOT error_code EQUAL "0")
        file(READ "${log_out}" out_contents)
        file(READ "${log_err}" err_contents)
        set(all_contents "${out_contents}${err_contents}")
        if(all_contents MATCHES "${Z_VCPKG_EXECUTE_BUILD_PROCESS_RETRY_ERROR_MESSAGES}")
            message(WARNING "Please ensure your system has sufficient memory.")
            set(log_out "${log_prefix}-out-1.log")
            set(log_err "${log_prefix}-err-1.log")
            list(APPEND all_logs "${log_out}" "${log_err}")

            if(DEFINED arg_NO_PARALLEL_COMMAND)
                message(STATUS "Restarting build without parallelism")
                execute_process(
                    COMMAND ${arg_NO_PARALLEL_COMMAND}
                    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
                    OUTPUT_FILE "${log_out}"
                    ERROR_FILE "${log_err}"
                    RESULT_VARIABLE error_code
                )
            else()
                message(STATUS "Restarting build")
                execute_process(
                    COMMAND ${arg_COMMAND}
                    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
                    OUTPUT_FILE "${log_out}"
                    ERROR_FILE "${log_err}"
                    RESULT_VARIABLE error_code
                )
            endif()
        elseif(all_contents MATCHES "mt : general error c101008d: ")
            # Antivirus workaround - occasionally files are locked and cause mt.exe to fail
            message(STATUS "mt.exe has failed. This may be the result of anti-virus. Disabling anti-virus on the buildtree folder may improve build speed")
            foreach(iteration RANGE 1 3)
                message(STATUS "Restarting Build ${TARGET_TRIPLET}-${SHORT_BUILDTYPE} because of mt.exe file locking issue. Iteration: ${iteration}")

                set(log_out "${log_prefix}-out-${iteration}.log")
                set(log_err "${log_prefix}-err-${iteration}.log")
                list(APPEND all_logs "${log_out}" "${log_err}")
                execute_process(
                    COMMAND ${arg_COMMAND}
                    WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
                    OUTPUT_FILE "${log_out}"
                    ERROR_FILE "${log_err}"
                    RESULT_VARIABLE error_code
                )

                if(error_code EQUAL "0")
                    break()
                endif()

                file(READ "${log_out}" out_contents)
                file(READ "${log_err}" err_contents)
                set(all_contents "${out_contents}${err_contents}")
                if(NOT all_contents MATCHES "mt : general error c101008d: ")
                    break()
                endif()
            endforeach()
        endif()
    endif()

    if(NOT error_code EQUAL "0")
        set(stringified_logs "")
        foreach(log IN LISTS all_logs)
            if(NOT EXISTS "${log}")
                continue()
            endif()
            file(SIZE "${log}" log_size)
            if(NOT log_size EQUAL "0")
                file(TO_NATIVE_PATH "${log}" native_log)
                string(APPEND stringified_logs "    ${native_log}\n")
                file(APPEND "${Z_VCPKG_ERROR_LOG_COLLECTION_FILE}" "${native_log}\n")
            endif()
        endforeach()
        z_vcpkg_prettify_command_line(pretty_command ${arg_COMMAND})
        message(FATAL_ERROR
            "  Command failed: ${pretty_command}\n"
            "  Working Directory: ${arg_WORKING_DIRECTORY}\n"
            "  See logs for more information:\n"
            "${stringified_logs}"
        )
    endif()
endfunction()
