if (NOT DEFINED OVERRIDEN_EXECUTE_PROCESS)
set(OVERRIDEN_EXECUTE_PROCESS ON)

function(execute_process)
  cmake_parse_arguments(overriden_execute_process "ALLOW_IN_DOWNLOAD_MODE" "" "" ${ARGV})
  
  if (NOT overriden_execute_process_ALLOW_IN_DOWNLOAD_MODE)
    if (DEFINED VCPKG_DOWNLOAD_MODE)
        message(FATAL_ERROR 
[[
  This command cannot be executed in Download Mode.
  Halting portfile execution.
]])
    endif()

    set(overriden_execute_process_ARGV ${ARGV})
  else()
    # Skip the first argument that corresponds to ALLOW_IN_DOWNLOAD_MODE.
    list(SUBLIST ARGV 1 -1 overriden_execute_process_ARGV)
  endif()
    
  _execute_process(${overriden_execute_process_ARGV})
endfunction()

endif()