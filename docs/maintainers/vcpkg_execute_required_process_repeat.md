# vcpkg_execute_required_process_repeat

Execute a process until the command succeeds, or until the COUNT is reached.

## Usage
```cmake
vcpkg_execute_required_process_repeat(
    COUNT <num>
    COMMAND <cmd> [<arguments>]
    WORKING_DIRECTORY <directory>
    LOGNAME <name>
)
```

## Source
[scripts/cmake/vcpkg_execute_required_process_repeat.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_execute_required_process_repeat.cmake)
