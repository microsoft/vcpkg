function(vcpkg_user_hint_on_failure message)
    file(APPEND "${Z_VCPKG_USER_HINTS_ON_BUILD_FAILURE_FILE}" "${message}\n")
endfunction()
