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

## Source
[scripts/cmake/vcpkg_execute_in_download_mode.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_execute_in_download_mode.cmake)
