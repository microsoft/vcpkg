## # execute_process
##
## Intercepts all calls to execute_process() inside portfiles.  
## All parameters except `ALLOW_IN_DOWNLOAD_MODE` are forwarded to 
## [CMake's execute_process](https://cmake.org/cmake/help/latest/command/execute_process.html)
##
## ## USAGE
## ```cmake
## execute_process(
##     [ALLOW_IN_DOWNLOAD_MODE]
##     COMMAND <${PERL}> [<arguments>...]
## )
## ```
##
## ## PARAMETERS
##
## ### ALLOW_IN_DOWNLOAD_MODE
## Allows commands to execute when `VCPKG_DOWNLOAD_MODE` is defined.  
##
## The `VCPKG_DOWNLOAD_MODE` definition is added when commands use the `--only-downloads`
## option, the purpose of **Download Mode** is to only allow execution of 
## commands that fetch sources or tools required for building a package.  
##
## The actual build process is not executed in **Download Mode**, and the portfile
## execution halts when a unqualified `execute_process()` command is called.
##
## ## NOTES
##
## This function accepts the same parameters as CMake's built-in `execute_process()`, all 
## parameters besides `ALLOW_IN_DOWNLOAD_MODE` are forwarded to `execute_process()`.
##
## ## EXAMPLES
##
## * [vcpkg_download_distfile()](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_download_distfile.cmake)
## * [vcpkg_execute_required_process()](https://github.com/Microsoft/vcpkg/blob/master//scripts/cmake/vcpkg_execute_required_process.cmake)
##
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