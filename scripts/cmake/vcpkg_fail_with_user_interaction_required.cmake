function(vcpkg_fail_with_user_interaction_required message)
    file(APPEND "${Z_VCPKG_REQUIRED_USER_INTERACTION_ON_BUILD_FAILURE_FILE}" "${message}")
    message(FATAL_ERROR "${message}")
endfunction()
