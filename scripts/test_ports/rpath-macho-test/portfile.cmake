set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

foreach(dir IN ITEMS tools/rpath-macho-test-binaries manual-tools/rpath-macho-test-binaries)
    string(REPLACE "/" "_" logname "execute-rel-${dir}")
    vcpkg_execute_required_process(
        COMMAND "${CURRENT_INSTALLED_DIR}/${dir}/rpath-macho-test-tool"
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
    foreach(dir IN ITEMS tools/rpath-macho-test-binaries/debug manual-tools/rpath-macho-test-binaries/debug debug/tools/rpath-macho-test-binaries)
        string(REPLACE "/" "_" logname "execute-dbg-${dir}")
        vcpkg_execute_required_process(
            COMMAND "${CURRENT_INSTALLED_DIR}/${dir}/rpath-macho-test-tool"
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

function(check_proper_rpath macho_lib)
    vcpkg_execute_required_process(
        COMMAND "otool" "-L" "${macho_lib}"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        OUTPUT_VARIABLE output
        OUTPUT_STRIP_TRAILING_WHITESPACE
        LOGNAME "${logname}"
    )

    set(found_rpath_backend_lib OFF)

    string(REPLACE "\n" ";" output_lines "${output}")
    # Ignore first line, it contains the path to the lib which we are checking
    list(REMOVE_AT output_lines 0)
    foreach(line IN LISTS output_lines)
        if("${line}" MATCHES "\\s+/.*librpath-macho-backend-lib\\+\\+\\.dylib")
            message(SEND_ERROR "${line} contains an absolute path")
        endif()
        if("${line}" MATCHES "@rpath/librpath-macho-backend-lib\\+\\+.dylib")
            set(found_rpath_backend_lib ON)
        endif()
    endforeach()

    if(NOT found_rpath_backend_lib)
        message(SEND_ERROR "@rpath/librpath-macho-backend-lib++.dylib not found in ${output}")
    endif()
endfunction()

check_proper_rpath("${CURRENT_INSTALLED_DIR}/lib/librpath-macho-test-lib.dylib")
check_proper_rpath("${CURRENT_INSTALLED_DIR}/debug/lib/librpath-macho-test-lib.dylib")
