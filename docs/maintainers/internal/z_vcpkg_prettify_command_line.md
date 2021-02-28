# z_vcpkg_prettify_command_line

**Only for internal use in vcpkg helpers. Behavior and arguments will change without notice.**
Turn a command line into a formatted string.

```cmake
z_vcpkg_prettify_command_line(<out-var> <argument>...)
```

This command is for internal use, when printing out to a message.

## Examples

* `scripts/cmake/vcpkg_execute_build_process.cmake`
* `scripts/cmake/vcpkg_execute_required_process.cmake`
* `scripts/cmake/vcpkg_execute_required_process_repeat.cmake`

## Source
[scripts/cmake/z_vcpkg_prettify_command_line.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/z_vcpkg_prettify_command_line.cmake)
