set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

foreach(dir IN ITEMS tools/rpath-test-binaries manual-tools/rpath-test-binaries)
    string(REPLACE "/" "_" logname "execute-rel-${dir}")
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_INSTALLED_DIR}/${dir}/rpath-test-tool"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        OUTPUT_VARIABLE output
        OUTPUT_STRIP_TRAILING_WHITESPACE
        LOGNAME "${logname}"
    )
    if(NOT output STREQUAL "release")
        message(SEND_ERROR "${dir}: $Actual: '${output}', expected: 'release'")
    endif()
endforeach()

if(NOT VCPKG_BUILD_TYPE)
    foreach(dir IN ITEMS tools/rpath-test-binaries/debug manual-tools/rpath-test-binaries/debug debug/tools/rpath-test-binaries)
        string(REPLACE "/" "_" logname "execute-dbg-${dir}")
        vcpkg_execute_required_process(
            COMMAND "${CURRENT_INSTALLED_DIR}/${dir}/rpath-test-tool"
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            OUTPUT_VARIABLE output
            OUTPUT_STRIP_TRAILING_WHITESPACE
            LOGNAME "${logname}"
        )
        if(NOT output STREQUAL "debug")
            message(SEND_ERROR "${dir}: Actual: '${output}', expected: 'debug'")
        endif()
    endforeach()
endif()
