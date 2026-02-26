function(vcpkg_libyal_msvscpp_convert)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        ""
        "SOLUTION;SOURCE_PATH;OUT_PROJECT_SUBPATH;VS_VERSION"
        "OPTIONS"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_SOLUTION)
        message(FATAL_ERROR "The SOLUTION is mandatory for ${CMAKE_CURRENT_FUNCTION}.")
    endif()

    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "The SOURCE_PATH is mandatory for ${CMAKE_CURRENT_FUNCTION}.")
    endif()

    if(NOT DEFINED arg_VS_VERSION)
        set(arg_VS_VERSION 2022)
        # Triplet variable
        if(DEFINED LIBYAL_VS_VERSION)
            set(arg_VS_VERSION "${LIBYAL_VS_VERSION}")
        endif()
    endif()

    cmake_path(GET arg_SOLUTION STEM LAST_ONLY basename)
    set(vs_project_subpath "vs${arg_VS_VERSION}/${basename}.sln")
    # Triplet variable
    if(DEFINED LIBYAL_VS_PROJECT_SUBPATH)
        set(vs_project_subpath "${LIBYAL_VS_PROJECT_SUBPATH}")
    endif()

    if(NOT DEFINED arg_OPTIONS)
        set(arg_OPTIONS --extend-with-x64 --no-python-dll)
    endif()

    z_vcpkg_libyal_vstools_download(vctools_path)
    vcpkg_find_acquire_program(PYTHON3)
    vcpkg_host_path_list(APPEND ENV{PYTHONPATH} "${vctools_path}")
    vcpkg_execute_required_process(
        COMMAND "${PYTHON3}" "${vctools_path}/scripts/msvscpp-convert.py" --output-format "${arg_VS_VERSION}" ${arg_OPTIONS} "${arg_SOLUTION}"
        WORKING_DIRECTORY "${arg_SOURCE_PATH}"
        LOGNAME "msvscpp-convert-${basename}-${TARGET_TRIPLET}"
    )

    set("${arg_OUT_PROJECT_SUBPATH}" "${vs_project_subpath}" PARENT_SCOPE)
endfunction()
