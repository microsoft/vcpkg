function(vcpkg_get_program_files_platform_bitness ret)

    set(ret_temp $ENV{ProgramW6432})
    if (NOT DEFINED ret_temp)
        set(ret_temp $ENV{PROGRAMFILES})
    endif()

    set(${ret} ${ret_temp} PARENT_SCOPE)

endfunction()