# By using bash builtin expansion, we can avoid
# expensively spawing three sub-processes (bash, echo, sed).
foreach(dir IN LISTS SOURCE_DIRS)
    file(READ "${dir}/configure" script)
    string(REGEX REPLACE
        "(\n[a-zA-Z0-9_]*)='`[\$]ECHO \"[\$]([^\"]*)\" \\| [\$]SED \"[\$]delay_single_quote_subst\"`'"
        [[\1='${\2//\\'/\\'\\\\\\'\\'}']]
        script "${script}"
    )
    string(REPLACE
        [[    case \`eval \\\\\$ECHO \\\\""\\\\\$\$var"\\\\"\` in]]
        [[    case "\${!var}" in]]
        script "${script}"
    )
    file(WRITE "${dir}/configure" "${script}")
endforeach()
