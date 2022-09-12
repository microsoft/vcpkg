function(vcpkg_execute_npm_command)
  cmake_parse_arguments(A "" "WORKING_DIRECTORY;OUTPUT_VARIABLE;RESULT_VARIABLE;NPM_COMMAND" "COMMAND" ${ARGN})
  foreach(arg WORKING_DIRECTORY COMMAND NPM_COMMAND)
    if("${A_${arg}}" STREQUAL "")
      message(FATAL_ERROR "Missing ${arg} argument")
    endif()
  endforeach()

  if(NOT IS_ABSOLUTE "${A_WORKING_DIRECTORY}")
    message(FATAL_ERROR "Expected WORKING_DIRECTORY to be an absolute path, but got: ${A_WORKING_DIRECTORY}")
  endif()

  #message(FATAL_ERROR "!!!!!!!!!!!${A_NPM_COMMAND}")
  execute_process(COMMAND "${A_NPM_COMMAND}" ${A_COMMAND}
    WORKING_DIRECTORY ${A_WORKING_DIRECTORY}
    RESULT_VARIABLE npm_result
    OUTPUT_VARIABLE npm_output
  )

  if("${A_RESULT_VARIABLE}" STREQUAL "")
    if(NOT "${npm_result}" STREQUAL "0")
      message(FATAL_ERROR "${A_NPM_COMMAND} ${A_COMMAND} exited with ${npm_result}:\n${npm_output}")
    endif()
  else()
    set("${A_RESULT_VARIABLE}" "${npm_result}" PARENT_SCOPE)
  endif()

  set("${A_OUTPUT_VARIABLE}" "${npm_output}" PARENT_SCOPE)
endfunction()
