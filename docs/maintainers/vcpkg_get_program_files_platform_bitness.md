# vcpkg_get_program_files_platform_bitness

Get the Program Files directory of the current platform's bitness:
either `$ENV{ProgramW6432}` on 64-bit windows,
or `$ENV{PROGRAMFILES}` on 32-bit windows.

## Usage:
```cmake
vcpkg_get_program_files_platform_bitness(<variable>)
```

## Source
[scripts/cmake/vcpkg_get_program_files_platform_bitness.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_get_program_files_platform_bitness.cmake)
