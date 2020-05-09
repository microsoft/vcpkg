# Returns Windows SDK path via out variable "ret"
function(vcpkg_get_windows_sdk_path ret)
    set(WINDOWS_SDK_PATH $ENV{WindowsSdkDir})
    get_filename_component(WindowsSdkDir "${WINDOWS_SDK_PATH}" DIRECTORY)
    set(${ret} ${WINDOWS_SDK_PATH} PARENT_SCOPE)
endfunction()