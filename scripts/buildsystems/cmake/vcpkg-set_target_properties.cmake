function(set_target_properties)
    set(_vcpkg_target_name ${ARGV0})
    vcpkg_msg(STATUS "set_target_properties" "${ARGV}")
    message("ARGC=\"${ARGC}\"")
    message("ARGN=\"${ARGN}\"")
    message("ARGV=\"${ARGV}\"")
    list(TRANSFORM "${ARGV}" REPLACE "" "\${_tmp_EMPTY}" OUTPUT_VARIABLE _tmp_args)
    _set_target_properties(${ARGV})
    if(NOT "${ARGV}" MATCHES "IMPORTED_LOCATION|IMPORTED_LOCATION_RELEASE|IMPORTED_LOCATION_DEBUG")
        return() # early abort to not generate too much noise. We are only interested in the above cases
    endif()
    get_target_property(_vcpkg_target_imported ${_vcpkg_target_name} IMPORTED)
    if(_vcpkg_target_imported)
        vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} is an IMPORTED target. Checking import location (if available)!")
        get_target_property(_vcpkg_target_imp_loc ${_vcpkg_target_name} IMPORTED_LOCATION)
        get_target_property(_vcpkg_target_imp_loc_rel ${_vcpkg_target_name} IMPORTED_LOCATION_RELEASE)
        get_target_property(_vcpkg_target_imp_loc_dbg ${_vcpkg_target_name} IMPORTED_LOCATION_DEBUG)
        # Release location
        if(_vcpkg_target_imp_loc_rel AND "${_vcpkg_target_imp_loc_rel}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
            vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} has property IMPORTED_LOCATION_RELEASE: ${_vcpkg_target_imp_loc_rel}. Checking for correct vcpkg path!")
            if("${_vcpkg_target_imp_loc_rel}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug")
                #This is the death case. If we reach this line the linkage of the target will be wrong!
                vcpkg_msg(FATAL_ERROR "set_target_properties" "Property IMPORTED_LOCATION_DEBUG: ${_vcpkg_target_imp_loc_rel}. Not set to vcpkg release library dir!" ALWAYS)
            else()
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION_RELEASE is correct: ${_vcpkg_target_imp_loc_rel}.")
            endif()
        endif()
        # Debug location
        if(_vcpkg_target_imp_loc_dbg AND "${_vcpkg_target_imp_loc_dbg}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
            vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} has property IMPORTED_LOCATION_DEBUG: ${_vcpkg_target_imp_loc_dbg}. Checking for correct vcpkg path!")
            if(NOT "${_vcpkg_target_imp_loc_dbg}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug")
                #This is the death case. If we reach this line the linkage of the target will be wrong!
                vcpkg_msg(FATAL_ERROR "set_target_properties" "Property IMPORTED_LOCATION_DEBUG: ${_vcpkg_target_imp_loc_dbg}. Not set to vcpkg debug library dir!" ALWAYS)
            else()
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION_DEBUG is correct: ${_vcpkg_target_imp_loc_dbg}.")
            endif()
        endif()
        # General import location
        if(_vcpkg_target_imp_loc AND "${_vcpkg_target_imp_loc}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")
             vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} has property IMPORTED_LOCATION: ${_vcpkg_target_imp_loc}. Checking for generator expression!")
            if("${_vcpkg_target_imp_loc}" MATCHES "\\$<\\$<CONFIG:DEBUG>:debug/>") # This generator expressions was added by vcpkgs find_library call
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION Contains generator expression inserted by vcpkg. Fixing locations.")
                string(REPLACE "$<$<CONFIG:DEBUG>:debug/>lib/" "lib/"       _vcpkg_target_imp_loc_rel_tmp "${_vcpkg_target_imp_loc}")
                string(REPLACE "$<$<CONFIG:DEBUG>:debug/>lib/" "debug/lib/" _vcpkg_target_imp_loc_dbg_tmp "${_vcpkg_target_imp_loc}")
                foreach(_vcpkg_debug_suffix ${VCPKG_ADDITIONAL_DEBUG_LIBNAME_SEARCH_SUFFIXES})
                    string(REPLACE "$<$<CONFIG:DEBUG>:${_vcpkg_debug_suffix}>" "" _vcpkg_target_imp_loc_rel_tmp "${_vcpkg_target_imp_loc_rel_tmp}")
                    string(REPLACE "$<$<CONFIG:DEBUG>:${_vcpkg_debug_suffix}>" "${_vcpkg_debug_suffix}" _vcpkg_target_imp_loc_dbg_tmp "${_vcpkg_target_imp_loc_dbg_tmp}")
                endforeach()
                _set_target_properties(${_vcpkg_target_name} 
                                        PROPERTIES 
                                            IMPORTED_LOCATION_RELEASE "${_vcpkg_target_imp_loc_rel_tmp}"
                                            IMPORTED_LOCATION_DEBUG "${_vcpkg_target_imp_loc_dbg_tmp}"
                                            IMPORTED_LOCATION "${_vcpkg_target_imp_loc_rel_tmp}")
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION_RELEASE set to: ${_vcpkg_target_imp_loc_rel_tmp}")
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION_DEBUG set to: ${_vcpkg_target_imp_loc_dbg_tmp}")
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION set to: ${_vcpkg_target_imp_loc_rel_tmp}")
            else()
                vcpkg_msg(STATUS "set_target_properties" "${_vcpkg_target_name} IMPORTED_LOCATION does not contain generator expression generated by vcpkg-find_library!")
            endif()
             # We cannot have generator expressions in general here. Need to move the location to to correct variables
        endif()
    endif()
endfunction()