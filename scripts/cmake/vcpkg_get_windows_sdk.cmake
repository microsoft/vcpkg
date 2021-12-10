#[===[.md:
# vcpkg_get_windows_sdk

Get the Windows SDK number.

## Usage:
```cmake
vcpkg_get_windows_sdk(<variable>)
```
#]===]

function(vcpkg_get_windows_sdk out_var)
    if("$ENV{WindowsSDKVersion}" MATCHES [[^([0-9.]*)\\?$]])
        set("${out_var}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Unexpected format for ENV{WindowsSDKVersion} ($ENV{WindowsSDKVersion})")
    endif()
endfunction()
