## # vcpkg_add_to_path
##
## Add a directory to the PATH environment variable
##
## ## Usage
## ```cmake
## vcpkg_add_to_path([PREPEND] <${PYTHON3_DIR}>)
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
## ## Examples:
## * [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake#L75)
## * [folly](https://github.com/Microsoft/vcpkg/blob/master/ports/folly/portfile.cmake#L15)
## * [z3](https://github.com/Microsoft/vcpkg/blob/master/ports/z3/portfile.cmake#L13)
##
function(vcpkg_add_to_path)
    if(NOT "${ARGC}" STREQUAL "1" AND NOT "${ARGC}" STREQUAL "2")
        message(FATAL_ERROR "vcpkg_add_to_path() only accepts 1 or 2 arguments.")
    endif()
    if("${ARGV0}" STREQUAL "PREPEND")
        if(NOT "${ARGC}" STREQUAL "2")
            message(FATAL_ERROR "Expected second argument.")
        endif()
        if(CMAKE_HOST_WIN32)
            set(ENV{PATH} "${ARGV1};$ENV{PATH}")
        else()
            set(ENV{PATH} "${ARGV1}:$ENV{PATH}")
        endif()
    else()
        if(NOT "${ARGC}" STREQUAL "1")
            message(FATAL_ERROR "Unexpected second argument: ${ARGV1}")
        endif()
        if(CMAKE_HOST_WIN32)
            set(ENV{PATH} "$ENV{PATH};${ARGV0}")
        else()
            set(ENV{PATH} "$ENV{PATH}:${ARGV0}")
        endif()
    endif()
endfunction()