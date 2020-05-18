# Returns Windows SDK directory out variable "ret"
function(vcpkg_get_windows_sdk_dir ret)
    set(WINDOWS_SDK_DIR $ENV{WindowsSdkDir})
    string(REGEX REPLACE "\\\\$" "" WINDOWS_SDK_DIR "${WINDOWS_SDK_DIR}")
    set(${ret} ${WINDOWS_SDK_DIR} PARENT_SCOPE)
endfunction()
