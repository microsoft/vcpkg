# vcpkg_execute_build_process

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_execute_build_process.md).

Execute a required build process

## Usage
```cmake
vcpkg_execute_build_process(
    COMMAND <cmd> [<args>...]
    [NO_PARALLEL_COMMAND <cmd> [<args>...]]
    WORKING_DIRECTORY </path/to/dir>
    LOGNAME <log_name>
)
```
## Parameters
### COMMAND
The command to be executed, along with its arguments.

### NO_PARALLEL_COMMAND
Optional parameter which specifies a non-parallel command to attempt if a
failure potentially due to parallelism is detected.

### WORKING_DIRECTORY
The directory to execute the command in.

### LOGNAME
The prefix to use for the log files.

This should be a unique name for different triplets so that the logs don't
conflict when building multiple at once.

## Examples

* [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_execute\_build\_process.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_execute_build_process.cmake)
