function(vcpkg_install_usage)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "FILE" "")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_FILE)
        message(FATAL_ERROR "FILE must be specified")
    endif()

    file(INSTALL "${arg_FILE}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "usage")
endfunction()
