function(vcpkg_escape_regex_control_characters out_var string_with_regex_characters)
  string(REGEX REPLACE "([][+.*()^\\])" "\\\\\\1" _vercc_out "${string_with_regex_characters}")
  set(${out_var} "${_vercc_out}" PARENT_SCOPE)
endfunction()
