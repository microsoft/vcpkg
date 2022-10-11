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

    # also checks for COUNT being an integer
    if(NOT arg_COUNT GREATER_EQUAL "1")
        message(FATAL_ERROR "COUNT (${arg_COUNT}) must be greater than or equal to 1.")
    endif()

    if (DEFINED VCPKG_DOWNLOAD_MODE AND NOT arg_ALLOW_IN_DOWNLOAD_MODE)
        message(FATAL_ERROR
[[
This command cannot be executed in Download Mode.
Halting portfile execution.
]])
    endif()

    if(X_PORT_PROFILE AND NOT arg_ALLOW_IN_DOWNLOAD_MODE)
        vcpkg_list(PREPEND arg_COMMAND "${CMAKE_COMMAND}" "-E" "time")
    endif()

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
            return()
        endif()
    endforeach()

    set(stringified_logs "")
    foreach(log IN LISTS all_logs)
        if(NOT EXISTS "${log}")
            continue()
        endif()
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
        "${stringified_logs}"
    )
endfunction()
