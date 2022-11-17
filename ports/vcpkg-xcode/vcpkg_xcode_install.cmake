include_guard(GLOBAL)

function(vcpkg_xcode_install)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "DISABLE_PARALLEL" "SOURCE_PATH;PROJECT_FILE;TARGET;SCHEME" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_xcode_install was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    
    set(args)
    foreach(arg IN ITEMS DISABLE_PARALLEL)
        if(arg_${arg})
            list(APPEND args "${arg}")
        endif()
    endforeach()
    
    vcpkg_xcode_build(
        ${args}
        SOURCE_PATH "${arg_SOURCE_PATH}"
        PROJECT_FILE "${arg_PROJECT_FILE}"
        LOGFILE_BASE install
        TARGET "${arg_TARGET}"
        SCHEME "${arg_SCHEME}"
        INSTALL
    )
endfunction()
