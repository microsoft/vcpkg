function(vcpkg_install_nmake)
    vcpkg_list(SET multi_value_args
        TARGET
        OPTIONS OPTIONS_DEBUG OPTIONS_RELEASE
        PRERUN_SHELL PRERUN_SHELL_DEBUG PRERUN_SHELL_RELEASE)

    cmake_parse_arguments(PARSE_ARGV 0 arg
        "NO_DEBUG;PREFER_JOM"
        "SOURCE_PATH;PROJECT_SUBPATH;PROJECT_NAME;CL_LANGUAGE"
        "${multi_value_args}"
    )
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified")
    endif()
    
    if(NOT VCPKG_HOST_IS_WINDOWS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} only support windows.")
    endif()

    # backwards-compatibility hack
    # gdal passes `arg_OPTIONS_DEBUG` (and RELEASE) as a single argument,
    # so we need to split them again
    set(arg_OPTIONS_DEBUG ${arg_OPTIONS_DEBUG})
    set(arg_OPTIONS_RELEASE ${arg_OPTIONS_RELEASE})
    
    vcpkg_list(SET extra_args)
    # switch args
    if(arg_NO_DEBUG)
        vcpkg_list(APPEND extra_args NO_DEBUG)
    endif()
    if(arg_PREFER_JOM)
        vcpkg_list(APPEND extra_args PREFER_JOM)
    endif()

    # single args
    foreach(arg IN ITEMS PROJECT_SUBPATH PROJECT_NAME CL_LANGUAGE)
        if(DEFINED "arg_${arg}")
            vcpkg_list(APPEND extra_args ${arg} "${arg_${arg}}")
        endif()
    endforeach()

    # multi-value args
    foreach(arg IN LISTS multi_value_args)
        if(DEFINED "arg_${arg}")
            vcpkg_list(APPEND extra_args ${arg} ${arg_${arg}})
        endif()
    endforeach()

    vcpkg_build_nmake(
        SOURCE_PATH "${arg_SOURCE_PATH}"
        ENABLE_INSTALL
        LOGFILE_ROOT install
        ${extra_args})
endfunction()
