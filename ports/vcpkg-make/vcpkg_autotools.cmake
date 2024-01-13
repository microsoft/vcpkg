function(vcpkg_autotools_configure)
  cmake_parse_arguments(PARSE_ARGV 0 arg
      ""
      "SOURCE_PATH;SHELL"
      ""
  )

  if(NOT arg_SHELL)
    vcpkg_make_get_shell(arg_SHELL)
  endif()
  set(shell_cmd "${arg_SHELL}")

  vcpkg_run_autoreconf("${shell_cmd}" "${arg_SOURCE_PATH}")

  vcpkg_make_configure(
    SHELL "${shell_cmd}"
    SOURCE_PATH "${arg_SOURCE_PATH}"
    ${arg_UNPARSED_ARGUMENTS}
  )
endfunction()
