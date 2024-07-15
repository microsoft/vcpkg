set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_execute_in_download_mode(
    COMMAND "${CURRENT_INSTALLED_DIR}/tools/rpath-test-binaries/rpath-test-tool"
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    OUTPUT_VARIABLE output
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT output STREQUAL "release")
    message(SEND_ERROR "Actual: '${output}', expected: 'release'")
endif()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_execute_in_download_mode(
        COMMAND "${CURRENT_INSTALLED_DIR}/tools/rpath-test-binaries/debug/rpath-test-tool"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        OUTPUT_VARIABLE output
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NOT output STREQUAL "debug")
        message(SEND_ERROR "Actual: '${output}', expected: 'debug'")
    endif()
endif()
