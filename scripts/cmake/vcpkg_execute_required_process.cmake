# Usage: vcpkg_execute_required_process(COMMAND <cmd> [<args>...] WORKING_DIRECTORY </path/to/dir> LOGNAME <my_log_name>)
function(vcpkg_execute_required_process)
    cmake_parse_arguments(vcpkg_execute_required_process "" "WORKING_DIRECTORY;LOGNAME" "COMMAND" ${ARGN})
    debug_message("vcpkg_execute_required_process(${vcpkg_execute_required_process_COMMAND})")
    execute_process(
        COMMAND ${vcpkg_execute_required_process_COMMAND}
        OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-out.log
        ERROR_FILE ${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-err.log
        RESULT_VARIABLE error_code
        WORKING_DIRECTORY ${vcpkg_execute_required_process_WORKING_DIRECTORY})
    #debug_message("error_code=${error_code}")
    file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}" NATIVE_BUILDTREES_DIR)
    if(error_code)
        message(FATAL_ERROR
            "Command failed: ${vcpkg_execute_required_process_COMMAND}\n"
            "Working Directory: ${vcpkg_execute_required_process_WORKING_DIRECTORY}\n"
            "See logs for more information:\n"
            "    ${NATIVE_BUILDTREES_DIR}\\${vcpkg_execute_required_process_LOGNAME}-out.log\n"
            "    ${NATIVE_BUILDTREES_DIR}\\${vcpkg_execute_required_process_LOGNAME}-err.log\n")
    endif()
endfunction()
