## # vcpkg_read_dependent_port_info
##
## reads in all vcpkg_port_info.cmake of all dependent ports of the current port and makes the variables available to use
##  
## ```
##
function(vcpkg_read_dependent_port_info)
        cmake_parse_arguments(_deps 
            ""
            "PORT"
            "FEATURES"
            ${ARGN}
        )
        
        if(NOT DEFINED _deps_PORT)
            set(_deps_PORT ${PORT})
        endif()

        if(NOT DEFINED _deps_FEATURES)
            set(_deps_FEATURES ${FEATURES})
        endif()

    vcpkg_get_build_depends(OUTPUT_VARIABLE ${_deps_PORT}_dependencies)
    foreach(port_dep_name ${${_deps_PORT}_dependencies})
        include(${CURRENT_INSTALLED_DIR}/share/${port_dep_name}/vcpkg_port_info.cmake)
        if(DEFINED ${port_dep_name}_DEPENDENCIES)
            foreach(port_dep_name_sec ${${port_dep_name}_DEPENDENCIES})
                vcpkg_read_dependent_port_info(PORT ${port_dep_name_sec} FEATURES ${${port_dep_name_sec}_FEATURES})
            endforeach()
        endif()
    endforeach()
    
endfunction()
