#/usr/bin/env bash

_vcpkg_completions()
{
  local vcpkg_executable=${COMP_WORDS[0]}
  local remaining_command_line=${COMP_LINE:(${#vcpkg_executable}+1)}
  COMPREPLY=($(${vcpkg_executable} autocomplete "${remaining_command_line}" -- 2>/dev/null))

  # Colon is treated as a delimiter in bash. The following workaround
  # allows triplet completion to work correctly in the syntax:
  # zlib:x64-windows
  local cur
  _get_comp_words_by_ref -n : cur
  __ltrim_colon_completions "$cur"
}

complete -F _vcpkg_completions vcpkg
