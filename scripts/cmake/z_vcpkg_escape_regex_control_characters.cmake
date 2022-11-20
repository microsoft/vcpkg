function(z_vcpkg_escape_regex_control_characters out_var string)
    if(ARGC GREATER "2")
        message(FATAL_ERROR "z_vcpkg_escape_regex_control_characters passed extra arguments: ${ARGN}")
    endif()
    # uses | instead of [] to avoid confusion; additionally, CMake doesn't support `]` in a `[]`
    string(REGEX REPLACE [[\[|\]|\(|\)|\.|\+|\*|\^|\\|\$|\?|\|]] [[\\\0]] escaped_content "${string}")
    set("${out_var}" "${escaped_content}" PARENT_SCOPE)
endfunction()
