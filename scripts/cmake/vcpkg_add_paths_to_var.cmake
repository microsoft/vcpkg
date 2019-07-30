## # vcpkg_add_paths_to_var
##
## Add a path to variable using the host dependent path seperator
##
## ## Usage
## ```cmake
## vcpkg_add_path_to_var(out_var [PREPEND] <${PYTHON3_DIR}> [...])
## ```
##
## ## Parameters
## ### <positional>
## The variable to add the paths to
## The paths to add to the variable
##
## ### PREPEND
## Prepends the given paths.
##
## The default is to append.
##

function(vcpkg_add_paths_to_var _out_var)
    cmake_parse_arguments(_vaptv "PREPEND" "" "" ${ARGN})

    if(CMAKE_HOST_WIN32)
        set(_SEP ;)
    else()
        set(_SEP :)
    endif()
    
    IF(${_out_var} MATCHES "ENV")
        string(REPLACE "ENV{" "" _out_var ${_out_var})
        string(REPLACE "}" "" _out_var ${_out_var})
        set(_vaptv_var "$ENV{${_out_var}}")
        set(_out_var_IS_ENV 1)
    else()
        set(_vaptv_var "${_out_var}")
    endif()
    
    message(STATUS "${_vaptv_var}")
    
    foreach(_vaptv_elems ${_vaptv_UNPARSED_ARGUMENTS})
        if(NOT EXISTS ${_vaptv_elems})
            message(WARNING "Adding non existing path to variable")
        endif()
        if(_vaptv_PREPEND)
            set(_vaptv_var "${_vaptv_elems}${_SEP}${_vaptv_var}")
        else()
            set(_vaptv_var "${_vaptv_var}${_SEP}${_vaptv_elems}")
        endif()
    endforeach()

    IF(_out_var_IS_ENV)
        set(ENV{${_out_var}} "${_vaptv_var}")
    else()
        set(${_out_var} "${_vaptv_var}" PARENT_SCOPE)
    endif()
endfunction()