#[===[.md:
# vcpkg_execute_required_process

Execute a process with logging and fail the build if the command fails.

## Usage
```cmake
vcpkg_execute_required_process(
    COMMAND <${PERL}> [<arguments>...]
    WORKING_DIRECTORY <${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg>
    LOGNAME <build-${TARGET_TRIPLET}-dbg>
    [TIMEOUT <seconds>]
    [OUTPUT_VARIABLE <var>]
    [ERROR_VARIABLE <var>]
)
```
## Parameters
### ALLOW_IN_DOWNLOAD_MODE
Allows the command to execute in Download Mode.  
[See execute_process() override](../../scripts/cmake/execute_process.cmake).

### COMMAND
The command to be executed, along with its arguments.

### WORKING_DIRECTORY
The directory to execute the command in.

### LOGNAME
The prefix to use for the log files.

### TIMEOUT
Optional timeout after which to terminate the command.

### OUTPUT_VARIABLE
Optional variable to receive stdout of the command.

### ERROR_VARIABLE
Optional variable to receive stderr of the command.

This should be a unique name for different triplets so that the logs don't conflict when building multiple at once.

## Examples

* [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
* [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
* [boost](https://github.com/Microsoft/vcpkg/blob/master/ports/boost/portfile.cmake)
* [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)
#]===]

include(vcpkg_prettify_command)
include(vcpkg_execute_in_download_mode)

function(vcpkg_execute_required_process)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 vcpkg_execute_required_process "ALLOW_IN_DOWNLOAD_MODE" "WORKING_DIRECTORY;LOGNAME;TIMEOUT;OUTPUT_VARIABLE;ERROR_VARIABLE" "COMMAND")
    set(LOG_OUT "${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-out.log")
    set(LOG_ERR "${CURRENT_BUILDTREES_DIR}/${vcpkg_execute_required_process_LOGNAME}-err.log")

    if(vcpkg_execute_required_process_TIMEOUT)
        set(TIMEOUT_PARAM "TIMEOUT;${vcpkg_execute_required_process_TIMEOUT}")
    else()
        set(TIMEOUT_PARAM "")
    endif()
    if(vcpkg_execute_required_process_OUTPUT_VARIABLE)
        set(OUTPUT_VARIABLE_PARAM "OUTPUT_VARIABLE;${vcpkg_execute_required_process_OUTPUT_VARIABLE}")
    else()
        set(OUTPUT_VARIABLE_PARAM "")
    endif()
    if(vcpkg_execute_required_process_ERROR_VARIABLE)
        set(ERROR_VARIABLE_PARAM "ERROR_VARIABLE;${vcpkg_execute_required_process_ERROR_VARIABLE}")
    else()
        set(ERROR_VARIABLE_PARAM "")
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
        ${TIMEOUT_PARAM}
        ${OUTPUT_VARIABLE_PARAM}
        ${ERROR_VARIABLE_PARAM})
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
    # pass output parameters back to caller's scope
    foreach(arg OUTPUT_VARIABLE ERROR_VARIABLE)
        if(vcpkg_execute_required_process_${arg})
            set(${vcpkg_execute_required_process_${arg}} ${${vcpkg_execute_required_process_${arg}}} PARENT_SCOPE)
        endif()
    endforeach()
endfunction()
