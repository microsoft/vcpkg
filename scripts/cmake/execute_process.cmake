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
      # parse parameters such that semicolons in arguments to COMMAND don't get erased
      cmake_parse_arguments(PARSE_ARGV 0 overriden_execute_process
                            "OUTPUT_QUIET;ERROR_QUIET;OUTPUT_STRIP_TRAILING_WHITESPACE;ERROR_STRIP_TRAILING_WHITESPACE"
                            "WORKING_DIRECTORY;TIMEOUT;RESULT_VARIABLE;RESULTS_VARIABLE;OUTPUT_VARIABLE;ERROR_VARIABLE;INPUT_FILE;OUTPUT_FILE;ERROR_FILE;ENCODING"
                            "COMMAND")

      # overriden_execute_process_COMMAND contains all commands' arguments concatenated together (yes, there can be multiple COMMANDs)
      # - we need to separate the commands and prepend COMMAND to each command's arguments
      # - to find out where the next command's arguments begin, we need to iterate over the original input (ARGV)
      # - as ARGV however is screwed up, we won't find the same elements as in correctly parsed overriden_execute_process_COMMAND,
      #   so we need to search elements of overriden_execute_process_COMMAND that start with the fractional element found in ARGV after COMMAND
      # - we can't use list(INSERT ...) as this breaks escaped semicolons; thus, we iterate and rebuild overriden_execute_process_COMMAND with COMMANDs added
      set(rebuilt_commands "")
      # search first command's first argument
      math(EXPR last_idx "${ARGC} - 1")
      set(first_arg_idx 0)
      set(more_commands_following 0)
      foreach(idx RANGE ${first_arg_idx} ${last_idx})
        list(GET ARGV ${idx} arg)
        if(arg STREQUAL COMMAND)
          set(more_commands_following 1)
          math(EXPR first_arg_idx "${idx} + 1")
          list(GET ARGV ${first_arg_idx} first_fractional_arg)
          # we need to escape all regex special charaters because we want to use first_fractional_arg in regex matching
          string(REGEX REPLACE "([][.?*+|()^$])" "\\\\\\1" first_fractional_arg "${first_fractional_arg}")
          break()
        endif()
      endforeach()
      # iterate and rebuild overriden_execute_process_COMMAND
      foreach(arg2 ${overriden_execute_process_COMMAND})
        if(more_commands_following AND arg2 MATCHES "^${first_fractional_arg}")
          list(APPEND rebuilt_commands COMMAND)
          # search next command's first argument
          set(more_commands_following 0)
          foreach(idx RANGE ${first_arg_idx} ${last_idx})
            list(GET ARGV ${idx} arg)
            if(arg STREQUAL COMMAND)
              set(more_commands_following 1)
              math(EXPR first_arg_idx "${idx} + 1")
              list(GET ARGV ${first_arg_idx} first_fractional_arg)
              # we need to escape all regex special charaters because we want to use first_fractional_arg in regex matching
              string(REGEX REPLACE "([][.?*+|()^$])" "\\\\\\1" first_fractional_arg "${first_fractional_arg}")
              break()
            endif()
          endforeach()
        endif()
        # double escape argument so that list finally contains once escaped argument
        string(REPLACE ";" "\\\\;" escaped_arg "${arg2}")
        list(APPEND rebuilt_commands ${escaped_arg})
      endforeach()

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

      _execute_process(${rebuilt_commands} ${other_args})

      # pass output parameters back to caller's scope
      foreach(arg RESULT_VARIABLE RESULTS_VARIABLE OUTPUT_VARIABLE ERROR_VARIABLE)
        if(overriden_execute_process_${arg})
          set(${overriden_execute_process_${arg}} ${${overriden_execute_process_${arg}}} PARENT_SCOPE)
        endif()
      endforeach()
    endfunction()
  endif()
endif()