#[===[.md:
# vcpkg_get_windows_sdk

Get the Windows SDK number.

## Usage:
```cmake
vcpkg_get_windows_sdk(<variable>)
```
#]===]

function(vcpkg_get_windows_sdk ret)
    set(WINDOWS_SDK $ENV{WindowsSDKVersion})
    string(REPLACE "\\" "" WINDOWS_SDK "${WINDOWS_SDK}")
    set(${ret} ${WINDOWS_SDK} PARENT_SCOPE)
endfunction()
