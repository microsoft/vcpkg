function(vcpkg_get_windows_sdk ret)
    execute_process(
        COMMAND powershell.exe ${VCPKG_ROOT_DIR}/scripts/getWindowsSDK.ps1
        OUTPUT_VARIABLE WINDOWS_SDK
        RESULT_VARIABLE error_code)

    if (${error_code})
        message(FATAL_ERROR "Could not find Windows SDK")
    endif()

    # Remove trailing newline
    string(REGEX REPLACE "\n$" "" WINDOWS_SDK "${WINDOWS_SDK}")

    set(${ret} ${WINDOWS_SDK} PARENT_SCOPE)
endfunction()