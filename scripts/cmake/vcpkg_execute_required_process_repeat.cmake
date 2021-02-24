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
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 vcpkg_execute_required_process_repeat "ALLOW_IN_DOWNLOAD_MODE" "COUNT;WORKING_DIRECTORY;LOGNAME" "COMMAND")
    #debug_message("vcpkg_execute_required_process_repeat(${vcpkg_execute_required_process_repeat_COMMAND})")
    if (DEFINED VCPKG_DOWNLOAD_MODE AND NOT vcpkg_execute_required_process_repeat_ALLOW_IN_DOWNLOAD_MODE)
        message(FATAL_ERROR
[[
This command cannot be executed in Download Mode.
Halting portfile execution.
]])
    endif()
    set(SUCCESSFUL_EXECUTION FALSE)
    foreach(loop_count RANGE ${vcpkg_execute_required_process_repeat_COUNT})
        vcpkg_execute_in_download_mode(
            COMMAND ${vcpkg_execute_required_process_repeat_COMMAND}
            OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_repeat_LOGNAME}-out-${loop_count}.log
            ERROR_FILE ${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_repeat_LOGNAME}-err-${loop_count}.log
            RESULT_VARIABLE error_code
            WORKING_DIRECTORY ${vcpkg_execute_required_process_repeat_WORKING_DIRECTORY})
        #debug_message("error_code=${error_code}")
        file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}" NATIVE_BUILDTREES_DIR)
        if(NOT error_code)
            set(SUCCESSFUL_EXECUTION TRUE)
            break()
        endif()
    endforeach(loop_count)
    if (NOT SUCCESSFUL_EXECUTION)
        z_vcpkg_prettify_command_line(vcpkg_execute_required_process_repeat_COMMAND_PRETTY ${vcpkg_execute_required_process_repeat_COMMAND})
        message(FATAL_ERROR
            "  Command failed: ${vcpkg_execute_required_process_repeat_COMMAND_PRETTY}\n"
            "  Working Directory: ${vcpkg_execute_required_process_repeat_WORKING_DIRECTORY}\n"
            "  See logs for more information:\n"
            "    ${NATIVE_BUILDTREES_DIR}\\${vcpkg_execute_required_process_repeat_LOGNAME}-out.log\n"
            "    ${NATIVE_BUILDTREES_DIR}\\${vcpkg_execute_required_process_repeat_LOGNAME}-err.log\n"
        )
    endif()
endfunction()
