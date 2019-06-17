## # vcpkg_add_to_lib
##
## Add a directory to the LIB environment variable
##
## ## Usage
## ```cmake
## vcpkg_add_to_lib([PREPEND] <${PYTHON3_DIR}>)
## ```
##
## ## Parameters
## ### <positional>
## The directory to add
##
## ### PREPEND
## Prepends the directory.
##
## The default is to append.
##
function(vcpkg_add_to_lib)
    if(NOT "${ARGC}" STREQUAL "1" AND NOT "${ARGC}" STREQUAL "2")
        message(FATAL_ERROR "vcpkg_add_to_lib() only accepts 1 or 2 arguments.")
    endif()
    if("${ARGV0}" STREQUAL "PREPEND")
        if(NOT "${ARGC}" STREQUAL "2")
            message(FATAL_ERROR "Expected second argument.")
        endif()
        if(CMAKE_HOST_WIN32)
            set(ENV{LIB} "${ARGV1};$ENV{LIB}")
        else()
            set(ENV{LD_LIBRARY_PATH} "${ARGV1}:$ENV{LD_LIBRARY_PATH}")
        endif()
    else()
        if(NOT "${ARGC}" STREQUAL "1")
            message(FATAL_ERROR "Unexpected second argument: ${ARGV1}")
        endif()
        if(CMAKE_HOST_WIN32)
            set(ENV{LIB} "$ENV{LIB};${ARGV0}")
        else()
            set(ENV{LD_LIBRARY_PATH} "$ENV{LD_LIBRARY_PATH}:${ARGV0}")
        endif()
    endif()
endfunction()
