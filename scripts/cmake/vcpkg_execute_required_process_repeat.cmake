#[===[.md:
# vcpkg_execute_required_process_repeat

Execute a process until the command succeeds, or until the COUNT is reached.

## Usage
```cmake
vcpkg_execute_required_process_repeat(
    COUNT <num>
    COMMAND <cmd> [<arguments>]
    WORKING_DIRECTORY <directory>
    LOGNAME <name>
)
```
#]===]

function(vcpkg_execute_required_process_repeat)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ALLOW_IN_DOWNLOAD_MODE"
        "COUNT;WORKING_DIRECTORY;LOGNAME"
        "COMMAND"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    foreach(required_arg IN ITEMS COUNT WORKING_DIRECTORY LOGNAME COMMAND)
        if(NOT DEFINED arg_${required_arg})
            message(FATAL_ERROR "${required_arg} must be specified.")
        endif()
    endforeach()

    if(COUNT LESS "1")
        message(FATAL_ERROR "COUNT must be greater than or equal to 1.")
    endif()

    if (DEFINED VCPKG_DOWNLOAD_MODE AND NOT arg_ALLOW_IN_DOWNLOAD_MODE)
        message(FATAL_ERROR
[[
This command cannot be executed in Download Mode.
Halting portfile execution.
]])
    endif()

    set(success OFF)
    set(all_logs "")
    foreach(loop_count RANGE 1 ${arg_COUNT})
        set(out_log "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-out-${loop_count}.log")
        set(err_log "${CURRENT_BUILDTREES_DIR}/${arg_LOGNAME}-out-${loop_count}.log")
        list(APPEND all_logs "${out_log}" "${err_log}")

        vcpkg_execute_in_download_mode(
            COMMAND ${arg_COMMAND}
            OUTPUT_FILE "${out_log}"
            ERROR_FILE "${err_log}"
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        )
        if(error_code EQUAL "0")
            set(success TRUE)
            break()
        endif()
    endforeach()

    if(NOT success)
        set(stringified_logs "")
        foreach(log IN LISTS all_logs)
            file(SIZE "${log}" log_size)
            if(NOT log_size EQUAL "0")
                file(TO_NATIVE_PATH "${log}" native_log)
                string(APPEND stringified_logs "    ${native_log}\n")
            endif()
        endforeach()

        z_vcpkg_prettify_command_line(pretty_command ${arg_COMMAND})
        message(FATAL_ERROR
            "  Command failed: ${pretty_command}\n"
            "  Working Directory: ${arg_WORKING_DIRECTORY}\n"
            "  See logs for more information:\n"
            "${stringifed_logs}"
        )
    endif()
endfunction()
