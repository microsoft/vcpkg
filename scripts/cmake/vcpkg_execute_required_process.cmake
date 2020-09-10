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
##     [TIMEOUT <seconds>]
## )
## ```
## ## Parameters
## ### ALLOW_IN_DOWNLOAD_MODE
## Allows the command to execute in Download Mode.  
## [See execute_process() override](../../scripts/cmake/execute_process.cmake).
##
## ### COMMAND
## The command to be executed, along with its arguments.
##
## ### WORKING_DIRECTORY
## The directory to execute the command in.
##
## ### LOGNAME
## The prefix to use for the log files.
##
## ### TIMEOUT
## Optional timeout after which to terminate the command.
##
## This should be a unique name for different triplets so that the logs don't conflict when building multiple at once.
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
## * [boost](https://github.com/Microsoft/vcpkg/blob/master/ports/boost/portfile.cmake)
## * [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)

include(vcpkg_prettify_command)
include(vcpkg_execute_in_download_mode)

function(vcpkg_execute_required_process)
    cmake_parse_arguments(vcpkg_execute_required_process "ALLOW_IN_DOWNLOAD_MODE" "WORKING_DIRECTORY;LOGNAME;TIMEOUT" "COMMAND" ${ARGN})
    set(LOG_OUT "${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-out.log")
    set(LOG_ERR "${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-err.log")

    if(vcpkg_execute_required_process_TIMEOUT)
      set(TIMEOUT_PARAM "TIMEOUT;${vcpkg_execute_required_process_TIMEOUT}")
    else()
      set(TIMEOUT_PARAM "")
    endif()

    if (DEFINED VCPKG_DOWNLOAD_MODE AND NOT vcpkg_execute_required_process_ALLOW_IN_DOWNLOAD_MODE)
        message(FATAL_ERROR 
[[
This command cannot be executed in Download Mode.
Halting portfile execution.
]])
    endif()

    vcpkg_execute_in_download_mode(
        COMMAND ${vcpkg_execute_required_process_COMMAND}
        OUTPUT_FILE ${LOG_OUT}
        ERROR_FILE ${LOG_ERR}
        RESULT_VARIABLE error_code
        WORKING_DIRECTORY ${vcpkg_execute_required_process_WORKING_DIRECTORY}
        ${TIMEOUT_PARAM})
    if(error_code)
        set(LOGS)
        file(READ "${LOG_OUT}" out_contents)
        file(READ "${LOG_ERR}" err_contents)
        if(out_contents)
            list(APPEND LOGS "${LOG_OUT}")
        endif()
        if(err_contents)
            list(APPEND LOGS "${LOG_ERR}")
        endif()
        set(STRINGIFIED_LOGS)
        foreach(LOG ${LOGS})
            file(TO_NATIVE_PATH "${LOG}" NATIVE_LOG)
            list(APPEND STRINGIFIED_LOGS "    ${NATIVE_LOG}\n")
        endforeach()
        vcpkg_prettify_command(vcpkg_execute_required_process_COMMAND vcpkg_execute_required_process_COMMAND_PRETTY)
        message(FATAL_ERROR
            "  Command failed: ${vcpkg_execute_required_process_COMMAND_PRETTY}\n"
            "  Working Directory: ${vcpkg_execute_required_process_WORKING_DIRECTORY}\n"
            "  Error code: ${error_code}\n"
            "  See logs for more information:\n"
            ${STRINGIFIED_LOGS}
        )
    endif()
endfunction()
