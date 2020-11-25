# vcpkg_execute_in_download_mode

Execute a process even in download mode.

## Usage
```cmake
vcpkg_execute_in_download_mode(
    COMMAND <cmd> [<arguments>...]
    OUTPUT_QUIET ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY <dir>
    TIMEOUT <seconds>
    RESULT_VARIABLE <seconds>
    OUTPUT_VARIABLE <var_out>
    ERROR_VARIABLE <var_err>
    INPUT_FILE <f_in>
    OUTPUT_FILE <f_out>
    ERROR_FILE <f_err>
    ENCODING <enc>
)
```

The signature of this function is identical with `execute_process()` except that
it only accepts one COMMAND argument, i.e., does not support chaining multiple
commands with pipes.

See `execute_process()` for a detailed description of the parameters.

## Source
[scripts/cmake/vcpkg_execute_in_download_mode.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_execute_in_download_mode.cmake)
