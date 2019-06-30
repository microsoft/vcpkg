# Usage: vcpkg_execute_required_process_repeat(COUNT <num> COMMAND <cmd> [<args>...] WORKING_DIRECTORY </path/to/dir> LOGNAME <my_log_name>)
include(vcpkg_prettify_command)
function(vcpkg_execute_required_process_repeat)
    cmake_parse_arguments(vcpkg_execute_required_process_repeat "" "COUNT;WORKING_DIRECTORY;LOGNAME" "COMMAND" ${ARGN})
    #debug_message("vcpkg_execute_required_process_repeat(${vcpkg_execute_required_process_repeat_COMMAND})")
    set(SUCCESSFUL_EXECUTION FALSE)
    foreach(loop_count RANGE ${vcpkg_execute_required_process_repeat_COUNT})
        execute_process(
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
        vcpkg_prettify_command(vcpkg_execute_required_process_repeat_COMMAND vcpkg_execute_required_process_repeat_COMMAND_PRETTY)
        message(FATAL_ERROR
            "  Command failed: ${vcpkg_execute_required_process_repeat_COMMAND_PRETTY}\n"
            "  Working Directory: ${vcpkg_execute_required_process_repeat_WORKING_DIRECTORY}\n"
            "  See logs for more information:\n"
            "    ${NATIVE_BUILDTREES_DIR}\\${vcpkg_execute_required_process_repeat_LOGNAME}-out.log\n"
            "    ${NATIVE_BUILDTREES_DIR}\\${vcpkg_execute_required_process_repeat_LOGNAME}-err.log\n"
        )
    endif()
endfunction()
