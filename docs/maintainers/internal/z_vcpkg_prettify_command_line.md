# z_vcpkg_prettify_command_line

Turn a command line into a formatted string.

```cmake
z_vcpkg_prettify_command_line(<out_var> <argument>...)
```

This command is for internal use, when printing out to a message.

## Examples

* `scripts/cmake/vcpkg_execute_build_process.cmake`
* `scripts/cmake/vcpkg_execute_required_process.cmake`
* `scripts/cmake/vcpkg_execute_required_process_repeat.cmake`

## Source
[scripts/cmake/z_vcpkg_prettify_command_line.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/z_vcpkg_prettify_command_line.cmake)
