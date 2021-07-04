#[===[.md:
# vcpkg_get_program_files_platform_bitness

Get the Program Files directory of the current platform's bitness:
either `$ENV{ProgramW6432}` on 64-bit windows,
or `$ENV{PROGRAMFILES}` on 32-bit windows.

## Usage:
```cmake
vcpkg_get_program_files_platform_bitness(<variable>)
```
#]===]

function(vcpkg_get_program_files_platform_bitness ret)

    set(ret_temp $ENV{ProgramW6432})
    if (NOT DEFINED ret_temp)
        set(ret_temp $ENV{PROGRAMFILES})
    endif()

    set(${ret} ${ret_temp} PARENT_SCOPE)

endfunction()
