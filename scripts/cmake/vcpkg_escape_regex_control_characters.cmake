function(vcpkg_escape_regex_control_characters out_var string_with_regex_characters)
  string(REGEX REPLACE "[][+.*()^\\$?|]" "\\\\\\0" _escaped_content "${string_with_regex_characters}")
  set(${out_var} "${_escaped_content}" PARENT_SCOPE)
endfunction()
