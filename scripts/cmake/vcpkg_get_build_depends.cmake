## # vcpkg_get_build_depends
##
## Get the dependent ports of the currently building port. Uses vcpkg depend-info
##
## ## Usage:
## ```cmake
## vcpkg_get_build_depends(
##      OUTPUT_VARIABLE <${OUTPUT_VARIABLE}>
##      [RECURSE_LEVEL <"1">]
##      [PORT <"qt5">])
##      [FEATURES <"latest">]
## ```
## ### OUTPUT_VARIABLE
## Variable which will be used to return the result of the function call
##
## ### RECURSE_LEVEL
## Sets the max recursion level of the vcpkg depend-info call (default=0). 
## Requires additional string manipulation of the output if not set to 0.
##
## ### PORT
## Port to request the dependcies of (default=${PORT}, currently building port)
##
## ### FEATURES
## specifies the features of port to request the dependencies of (default=${FEATURES})

function(vcpkg_get_build_depends)
        cmake_parse_arguments(_deps 
            ""
            "OUTPUT_VARIABLE;RECURSE_LEVEL;PORT"
            "FEATURES"
            ${ARGN}
        )
        
        if(NOT DEFINED _deps_OUTPUT_VARIABLE)
            message(FATAL_ERROR "vcpkg_get_build_depends requires parameter OUTPUT_VARIABLE")
        endif()
        
        if(NOT DEFINED _deps_RECURSE_LEVEL)
            set(_deps_RECURSE_LEVEL 0)
        endif()
        
        if(NOT DEFINED _deps_PORT)
            set(_deps_PORT ${PORT})
        endif()

        if(NOT DEFINED _deps_FEATURES)
            set(_deps_FEATURES ${FEATURES})
        endif()

        list(JOIN _deps_FEATURES ", " FEATURES_COMMA)
        find_program(VCPKG_PROG vcpkg PATHS ${VCPKG_ROOT_DIR})
        message(STATUS "${VCPKG_PROG} depend-info ${_deps_PORT}[${FEATURES_COMMA}] --max-recurse=${_deps_RECURSE_LEVEL}")
        execute_process(COMMAND ${VCPKG_PROG} depend-info ${_deps_PORT}[${FEATURES_COMMA}] --max-recurse=${_deps_RECURSE_LEVEL}
                            OUTPUT_VARIABLE ${_deps_OUTPUT_VARIABLE})
        #message(STATUS "Depend-Info: ${_deps_OUTPUT_VARIABLE}: ${${_deps_OUTPUT_VARIABLE}}")
        string(REGEX REPLACE "[^:]+: " "" "${_deps_OUTPUT_VARIABLE}" "${${_deps_OUTPUT_VARIABLE}}")
        string(REGEX REPLACE ", " ";" "${_deps_OUTPUT_VARIABLE}" "${${_deps_OUTPUT_VARIABLE}}")
        string(REGEX REPLACE "\n" "" "${_deps_OUTPUT_VARIABLE}" "${${_deps_OUTPUT_VARIABLE}}")
        message(STATUS "get: ${_deps_OUTPUT_VARIABLE}: ${${_deps_OUTPUT_VARIABLE}}")
        set(${_deps_OUTPUT_VARIABLE} ${${_deps_OUTPUT_VARIABLE}} PARENT_SCOPE)
endfunction()