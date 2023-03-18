function(vcpkg_install_usage)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "USAGE_FILE;DESTINATION" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_USAGE_FILE)
        set(arg_USAGE_FILE "${CURRENT_PORT_DIR}/usage")
    endif()

    if(NOT EXISTS "${arg_USAGE_FILE}")
        message(FATAL_ERROR "\n${CMAKE_CURRENT_FUNCTION} was passed a non-existing path: ${arg_USAGE_FILE}\n")
    endif()

    if(NOT DEFINED arg_DESTINATION)
        set(arg_DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    endif()

    file(INSTALL "${arg_USAGE_FILE}" DESTINATION "${arg_DESTINATION}" RENAME "usage")
endfunction()
