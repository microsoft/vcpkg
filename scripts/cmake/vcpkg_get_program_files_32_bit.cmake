function(vcpkg_get_program_files_32_bit ret)

    set(ret_temp $ENV{ProgramFiles\(X86\)})
    if (NOT DEFINED ret_temp)
        set(ret_temp $ENV{PROGRAMFILES})
    endif()

    set(${ret} ${ret_temp} PARENT_SCOPE)

endfunction()