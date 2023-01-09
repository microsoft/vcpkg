# vcpkg_execute_required_process

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_execute_required_process.md).

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
    [SAVE_LOG_FILES <relative-path> [ALIAS <unique-alias>] [<relative-path>...]]
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

### SAVE_LOG_FILES

Optional files to be moved from the working directory to `${CURRENT_BUILDTREES_DIR}`.
The files are copied even if the process failed. 
This helps to collect relevant log files in CI setups.

The target filename is constructed from the `LOGNAME` parameter and the parameter of the `ALIAS` keyword following the source path.
If `ALIAS` is absent, the target filename is constructed from the `LOGNAME` parameter, the source filename,
and the suffix `.log` if the source filename doesn't already end with this suffix.

## Examples

* [boost-build](https://github.com/Microsoft/vcpkg/blob/master/ports/boost-build/portfile.cmake)
* [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
* [qt5-base](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5-base/cmake/configure_qt.cmake)
* [vcpkg-cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake/vcpkg_cmake_configure.cmake)

## Source
[scripts/cmake/vcpkg\_execute\_required\_process.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_execute_required_process.cmake)
