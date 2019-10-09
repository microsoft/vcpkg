## # vcpkg_read_dependent_port_info
##
## reads in all vcpkg_port_info.cmake of all dependent ports of the current port and makes the variables available to use
##  
## ```
##
function(vcpkg_read_dependent_port_info)
        cmake_parse_arguments(_rdeps 
            ""
            "PORT"
            "FEATURES"
            ${ARGN}
        )
        
        if(NOT DEFINED _rdeps_PORT)
            set(_rdeps_PORT ${PORT})
        endif()

        if(NOT DEFINED _rdeps_FEATURES)
            set(_rdeps_FEATURES ${FEATURES})
        endif()

    vcpkg_get_build_depends(OUTPUT_VARIABLE ${_rdeps_PORT}_dependencies PORT ${_rdeps_PORT} FEATURES ${_rdeps_FEATURES})

    list(APPEND ${_rdeps_PORT}_ALL_DEPENDENCIES ${${_rdeps_PORT}_dependencies})
    
    vcpkg_read_dependent_recursion("${${_rdeps_PORT}_dependencies}" "${_rdeps_PORT}")

    message(STATUS "${PORT}_ALL_DEPENDENCIES: ${${PORT}_ALL_DEPENDENCIES}")
    message(STATUS "${_rdeps_PORT}_ALL_DEPENDENCIES: ${${_rdeps_PORT}_ALL_DEPENDENCIES}")
endfunction()

macro(vcpkg_read_dependent_recursion DEPENDENCY_LIST CURRENT_PORT)
    foreach(port_dep_name ${DEPENDENCY_LIST})
        message(STATUS "Including ${CURRENT_INSTALLED_DIR}/share/${port_dep_name}/vcpkg_port_info.cmake")
        include(${CURRENT_INSTALLED_DIR}/share/${port_dep_name}/vcpkg_port_info.cmake)
        if(DEFINED ${port_dep_name}_DEPENDENCIES)
            message(STATUS "${port_dep_name}_DEPENDENCIES: ${${port_dep_name}_DEPENDENCIES}")
            list(APPEND ${_rdeps_PORT}_ALL_DEPENDENCIES ${${port_dep_name}_DEPENDENCIES})
            if(NOT ${CURRENT_PORT} MATCHES ${_rdeps_PORT})
                list(APPEND ${CURRENT_PORT}_ALL_DEPENDENCIES ${${port_dep_name}_DEPENDENCIES})
            endif()
            vcpkg_read_dependent_recursion("${${port_dep_name}_DEPENDENCIES}" "${port_dep_name}")
        endif()
    endforeach()
    set(${_rdeps_PORT}_ALL_DEPENDENCIES ${${PORT}_ALL_DEPENDENCIES} CACHE INTERNAL "")
endmacro()
