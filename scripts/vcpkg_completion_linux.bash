#/usr/bin/env bash

# in .bashrc add: source ~/vcpkg/scripts/vcpkg_completion_linux.bash

_vcpkg_completions()
{
  local vcpkg_executable=${COMP_WORDS[0]}
  local remaining_command_line=${COMP_LINE:(${#vcpkg_executable}+1)}
  local opts=$(${vcpkg_executable} autocomplete "${remaining_command_line}")

  COMPREPLY=($(compgen -W "${opts}" -- ${remaining_command_line}) )
}

complete -F _vcpkg_completions vcpkg

