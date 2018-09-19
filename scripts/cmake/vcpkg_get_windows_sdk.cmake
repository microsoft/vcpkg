# Returns Windows SDK number via out variable "ret"
function(vcpkg_get_windows_sdk ret)
    set(WINDOWS_SDK $ENV{WindowsSDKVersion})
    string(REPLACE "\\" "" WINDOWS_SDK "${WINDOWS_SDK}")
    set(${ret} ${WINDOWS_SDK} PARENT_SCOPE)
endfunction()