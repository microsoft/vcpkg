option(VCPKG_VERBOSE "Enables messages from the VCPKG toolchain for debugging purposes." ON)
mark_as_advanced(VCPKG_VERBOSE)

function(vcpkg_msg _mode _function _message)
    cmake_parse_arguments(PARSE_ARGV 3 vcpkg-msg "ALWAYS" "" "")
    if(VCPKG_VERBOSE OR vcpkg-msg_ALWAYS)
        message(${_mode} "VCPKG-${_function}: ${_message}")
    endif()
endfunction()