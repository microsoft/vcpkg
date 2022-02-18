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

function(vcpkg_get_program_files_platform_bitness out_var)
    if(DEFINED ENV{ProgramW6432})
        set("${out_var}" "$ENV{ProgramW6432}" PARENT_SCOPE)
    else()
        set("${out_var}" "$ENV{PROGRAMFILES}" PARENT_SCOPE)
    endif()
endfunction()
