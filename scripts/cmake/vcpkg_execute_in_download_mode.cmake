#[===[.md:
# vcpkg_execute_in_download_mode

Execute a process even in download mode.

## Usage
```cmake
vcpkg_execute_in_download_mode(
    COMMAND <cmd> [<arguments>]
    [WORKING_DIRECTORY <dir>]
    [TIMEOUT <seconds>]
    [RESULT_VARIABLE <variable>]
    [OUTPUT_VARIABLE <variable>]
    [ERROR_VARIABLE <variable>]
    [INPUT_FILE <file>]
    [OUTPUT_FILE <file>]
    [ERROR_FILE <file>]
    [OUTPUT_QUIET]
    [ERROR_QUIET]
    [OUTPUT_STRIP_TRAILING_WHITESPACE]
    [ERROR_STRIP_TRAILING_WHITESPACE]
    [ENCODING <name>]
)
```

The signature of this function is identical to `execute_process()` except that
it only accepts one COMMAND argument, i.e., does not support chaining multiple
commands with pipes.

See [`execute_process()`] for a detailed description of the parameters.

[`execute_process()`]: https://cmake.org/cmake/help/latest/command/execute_process.html
#]===]

function(vcpkg_execute_in_download_mode)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 vcpkg_execute_in_download_mode
        "OUTPUT_QUIET;ERROR_QUIET;OUTPUT_STRIP_TRAILING_WHITESPACE;ERROR_STRIP_TRAILING_WHITESPACE"
        "WORKING_DIRECTORY;TIMEOUT;RESULT_VARIABLE;RESULTS_VARIABLE;OUTPUT_VARIABLE;ERROR_VARIABLE;INPUT_FILE;OUTPUT_FILE;ERROR_FILE;ENCODING"
        "COMMAND")

    # collect all other present parameters
    set(other_args "")
    foreach(arg OUTPUT_QUIET ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE)
        if(vcpkg_execute_in_download_mode_${arg})
            list(APPEND other_args ${arg})
        endif()
    endforeach()
    foreach(arg WORKING_DIRECTORY TIMEOUT RESULT_VARIABLE RESULTS_VARIABLE OUTPUT_VARIABLE ERROR_VARIABLE INPUT_FILE OUTPUT_FILE ERROR_FILE ENCODING)
        if(vcpkg_execute_in_download_mode_${arg})
            list(APPEND other_args ${arg} ${vcpkg_execute_in_download_mode_${arg}})
        endif()
    endforeach()

    if (DEFINED VCPKG_DOWNLOAD_MODE)
        _execute_process(COMMAND ${vcpkg_execute_in_download_mode_COMMAND} ${other_args})
    else()
        execute_process(COMMAND ${vcpkg_execute_in_download_mode_COMMAND} ${other_args})
    endif()

    # pass output parameters back to caller's scope
    foreach(arg RESULT_VARIABLE RESULTS_VARIABLE OUTPUT_VARIABLE ERROR_VARIABLE)
        if(vcpkg_execute_in_download_mode_${arg})
            set(${vcpkg_execute_in_download_mode_${arg}} ${${vcpkg_execute_in_download_mode_${arg}}} PARENT_SCOPE)
         endif()
    endforeach()
endfunction()
