# vcpkg_execute_in_download_mode

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_execute_in_download_mode.md).

Execute a process even in download mode.

## Usage
```cmake
vcpkg_execute_in_download_mode(
    ...
)
```

The signature of this function is identical to `execute_process()`.

See [`execute_process()`] for more details.

[`execute_process()`]: https://cmake.org/cmake/help/latest/command/execute_process.html

## Source
[scripts/cmake/vcpkg\_execute\_in\_download\_mode.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_execute_in_download_mode.cmake)
