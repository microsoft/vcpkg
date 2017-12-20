## # vcpkg_execute_required_process
##
## Execute a process with logging and fail the build if the command fails.
##
## ## Usage
## ```cmake
## vcpkg_execute_required_process(
##     COMMAND <${PERL}> [<arguments>...]
##     WORKING_DIRECTORY <${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg>
##     LOGNAME <build-${TARGET_TRIPLET}-dbg>
## )
## ```
## ## Parameters
## ### COMMAND
## The command to be executed, along with its arguments.
##
## ### WORKING_DIRECTORY
## The directory to execute the command in.
##
## ### LOGNAME
## The prefix to use for the log files.
##
## This should be a unique name for different triplets so that the logs don't conflict when building multiple at once.
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
## * [boost](https://github.com/Microsoft/vcpkg/blob/master/ports/boost/portfile.cmake)
## * [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)
function(vcpkg_execute_required_process)
    cmake_parse_arguments(vcpkg_execute_required_process "" "WORKING_DIRECTORY;LOGNAME" "COMMAND" ${ARGN})
    #debug_message("vcpkg_execute_required_process(${vcpkg_execute_required_process_COMMAND})")
    execute_process(
        COMMAND ${vcpkg_execute_required_process_COMMAND}
        OUTPUT_FILE ${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-out.log
        ERROR_FILE ${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-err.log
        RESULT_VARIABLE error_code
        WORKING_DIRECTORY ${vcpkg_execute_required_process_WORKING_DIRECTORY})
    #debug_message("error_code=${error_code}")
    if(error_code)
        file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-out.log" NATIVE_LOG_OUT)
        file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-err.log" NATIVE_LOG_ERR)
        message(FATAL_ERROR
            "  Command failed: ${vcpkg_execute_required_process_COMMAND}\n"
            "  Working Directory: ${vcpkg_execute_required_process_WORKING_DIRECTORY}\n"
            "  See logs for more information:\n"
            "    ${NATIVE_LOG_OUT}\n"
            "    ${NATIVE_LOG_ERR}\n")
    endif()
endfunction()
