include_guard(GLOBAL)

function(vcpkg_cmake_install)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "DISABLE_PARALLEL;ADD_BIN_TO_PATH" "" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_cmake_install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    set(args)
    foreach(arg IN ITEMS DISABLE_PARALLEL ADD_BIN_TO_PATH)
        if(arg_${arg})
            list(APPEND args "${arg}")
        endif()
    endforeach()

    vcpkg_cmake_build(
        ${args}
        LOGFILE_BASE install
        TARGET install
    )
endfunction()
