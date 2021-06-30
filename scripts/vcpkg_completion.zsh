
_vcpkg_completions()
{
  local vcpkg_executable=${COMP_WORDS[0]}
  local remaining_command_line=${COMP_LINE:(${#vcpkg_executable}+1)}
  COMPREPLY=($(${vcpkg_executable} autocomplete "${remaining_command_line}" -- 2>/dev/null))
}

complete -F _vcpkg_completions vcpkg
