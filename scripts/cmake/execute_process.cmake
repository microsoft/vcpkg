## # execute_process
##
## Intercepts all calls to execute_process() inside portfiles and fails when Download Mode
## is enabled.
##
## In order to execute a process in Download Mode call `_execute_process()` instead.
##
if (NOT DEFINED OVERRIDEN_EXECUTE_PROCESS)
  set(OVERRIDEN_EXECUTE_PROCESS ON)

  if (DEFINED VCPKG_DOWNLOAD_MODE)
    macro(execute_process)
      message(FATAL_ERROR "This command cannot be executed in Download Mode.\nHalting portfile execution.\n")
    endmacro()
  else()
    function(execute_process)
      # check that COMMAND is not supplied more than once; if there's ever a use case for this, the implementation below needs to be extended
      set(command_count 0)
      foreach(arg ${ARGV})
        if(arg STREQUAL COMMAND)
          math(EXPR command_count "${command_count} + 1")
        endif()
      endforeach()
      if(NOT command_count EQUAL 1)
        message(FATAL_ERROR "Overriden execute_process() function only supports 1 COMMAND parameter.\n")
      endif()

      # parse parameters such that semicolons in options arguments to COMMAND don't get erased
      cmake_parse_arguments(PARSE_ARGV 0 overriden_execute_process
                            "OUTPUT_QUIET;ERROR_QUIET;OUTPUT_STRIP_TRAILING_WHITESPACE;ERROR_STRIP_TRAILING_WHITESPACE"
                            "WORKING_DIRECTORY;TIMEOUT;RESULT_VARIABLE;RESULTS_VARIABLE;OUTPUT_VARIABLE;ERROR_VARIABLE;INPUT_FILE;OUTPUT_FILE;ERROR_FILE;ENCODING"
                            "COMMAND")

      # collect all other present parameters
      set(other_args "")
      foreach(arg OUTPUT_QUIET ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE)
        if(overriden_execute_process_${arg})
          list(APPEND other_args ${arg})
        endif()
      endforeach()
      foreach(arg WORKING_DIRECTORY TIMEOUT RESULT_VARIABLE RESULTS_VARIABLE OUTPUT_VARIABLE ERROR_VARIABLE INPUT_FILE OUTPUT_FILE ERROR_FILE ENCODING)
        if(overriden_execute_process_${arg})
          list(APPEND other_args ${arg} ${overriden_execute_process_${arg}})
        endif()
      endforeach()

      _execute_process(COMMAND ${overriden_execute_process_COMMAND} ${other_args})

      # pass output parameters back to caller's scope
      foreach(arg RESULT_VARIABLE RESULTS_VARIABLE OUTPUT_VARIABLE ERROR_VARIABLE)
        if(overriden_execute_process_${arg})
          set(${overriden_execute_process_${arg}} ${${overriden_execute_process_${arg}}} PARENT_SCOPE)
        endif()
      endforeach()
    endfunction()
  endif()
endif()