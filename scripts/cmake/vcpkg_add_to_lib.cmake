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
    if(NOT ("${ARGC}" STREQUAL "1" OR "${ARGC}" STREQUAL "2"))
        message(FATAL_ERROR "vcpkg_add_to_lib() only accepts 1 or 2 arguments.")
    endif()
    
    if(CMAKE_HOST_WIN32)
        set(_lib_var LIB)
    else()
        set(_lib_var LD_LIBRARY_PATH)
    endif()

    if("${ARGV0}" STREQUAL "PREPEND")
        if(NOT "${ARGC}" STREQUAL "2")
            message(FATAL_ERROR "Expected second argument.")
        endif()
        vcpkg_add_paths_to_var(ENV{${_lib_var}} PREPEND ${ARGV1})
    else()
        if(NOT "${ARGC}" STREQUAL "1")
            message(FATAL_ERROR "Unexpected second argument: ${ARGV1}")
        endif()
        vcpkg_add_paths_to_var(ENV{${_lib_var}} ${ARGV0})
    endif()
endfunction()
