#/usr/bin/env bash
#set -x

# to install add to ~/.bashrc:
#  > source ~/vcpkg/scripts/vcpkg_completion.bash

# details: bash and utilities from bash-completion
#          bash comands: compgen, complete
# input: COMP_WORDS, COMP_CWORD, COMP_LINE, COMP_POINT, COMP_KEY, COMP_WORDBREAKS
# output: COMPREPLY
_vcpkg_completions()
{
    local vcpkg_executable=${COMP_WORDS[0]}
    local remaining_command_line=${COMP_LINE:(${#vcpkg_executable}+1)}
    # echo "rem:$remaining_command_line"

    if [ $COMP_CWORD -eq 1 ]; then
        local opts=$(${vcpkg_executable} autocomplete ${remaining_command_line})
    else
        local opts=$(${vcpkg_executable} autocomplete ${remaining_command_line} --)
    fi
    #echo "opts:$opts"

    COMPREPLY=($(compgen -W "${opts}" -- ${COMP_WORDS[COMP_CWORD]}) )
    #echo "COMPREPLY:$COMPREPLY"
}

complete -F _vcpkg_completions vcpkg

