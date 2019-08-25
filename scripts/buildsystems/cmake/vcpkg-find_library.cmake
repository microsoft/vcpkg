
vcpkg_define_function_overwrite_option(find_library)

CMAKE_DEPENDENT_OPTION(VCPKG_ENABLE_FIND_LIBRARY_EXTERNAL_OVERRIDE "Tells VCPKG to use _find_library instead of find_library." OFF "NOT VCPKG_ENABLE_find_library" OFF)
mark_as_advanced(VCPKG_ENABLE_FIND_LIBRARY_EXTERNAL_OVERRIDE)

function(vcpkg_find_library _vcpkg_find_library_imp_output)
    cmake_policy(PUSH)
    cmake_policy(SET CMP0054 NEW)
    cmake_policy(SET CMP0012 NEW)
    
    # This fixes the parameter list given to find_library to
    # always include NAMES_PER_DIR because that is the prefered search order using vcpkg
    set(_vcpkg_list_vars "${ARGV}")
    set(options NAMES_PER_DIR 
                NO_DEFAULT_PATH 
                NO_PACKAGE_ROOT_PATH 
                NO_CMAKE_PATH 
                NO_CMAKE_ENVIRONMENT_PATH 
                NO_SYSTEM_ENVIRONMENT_PATH 
                NO_CMAKE_SYSTEM_PATH
                CMAKE_FIND_ROOT_PATH_BOTH 
                ONLY_CMAKE_FIND_ROOT_PATH 
                NO_CMAKE_FIND_ROOT_PATH)
    set(oneValueArgs DOC)
    set(multiValueArgs NAMES 
                       HINTS
                       PATHS
                       PATH_SUFFIXES)
    cmake_parse_arguments(PARSE_ARGV 0 _vcpkg_find_lib "${options}" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT DEFINED _vcpkg_find_lib_NAMES)
        if("${ARGV}" MATCHES "NAMES;") # the extra ; makes sure that it does not match NAMES_PER_DIR
            #NAMES in argument list but not parsed for some reason -> retry with old parser syntax
            vcpkg_msg(STATUS "find_library" "cmake_parse_arguments PARSE_ARGV not working correctly! Retrying!")
            cmake_parse_arguments(_vcpkg_find_lib "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
            if(NOT DEFINED _vcpkg_find_lib_NAMES)
                cmake_policy(POP)
                vcpkg_msg(FATAL_ERROR "find_library" "cmake_parse_arguments not working correctly!")
            else()
                # this will generate NAMES_POS+1 since ARGV is used and not ARGN; Moves it Behind NAMES
                list(FIND ARGV "NAMES" _insert_offset) 
                # this will generate NAMES_POS+2 since the offset must be set behind the first possible library name!
                math(EXPR _insert_offset "1+${_insert_offset}" OUTPUT_FORMAT DECIMAL) 
            endif()
        else()
            #NAMES not in argument list -> only single name
            set(_vcpkg_find_lib_NAMES ${ARGV1})
            set(_insert_offset 1)
        endif()
    else()
        list(FIND ARGV "NAMES" _insert_offset)
        math(EXPR _insert_offset "1+${_insert_offset}" OUTPUT_FORMAT DECIMAL) #reason see above
    endif()
    ##Insert NAMES_PER_DIR if not set!
    if(NOT _vcpkg_find_lib_NAMES_PER_DIR) 
        list(LENGTH _vcpkg_find_lib_NAMES _vcpkg_find_lib_NAMES_LENGTH)
        if(_vcpkg_find_lib_NAMES_LENGTH GREATER 0)
            math(EXPR _insert_pos "${_vcpkg_find_lib_NAMES_LENGTH}+${_insert_offset}" OUTPUT_FORMAT DECIMAL)
            list(INSERT _vcpkg_list_vars ${_insert_pos} NAMES_PER_DIR)
        else() # Logic programming error! (Treat it like an assert!)
            cmake_policy(POP)
            vcpkg_msg(STATUS "find_library-vars" "${_vcpkg_list_vars}")
            vcpkg_msg(FATAL_ERROR "find_library" "Could not insert NAMES_PER_DIR to find_library call. Length: ${_vcpkg_find_lib_NAMES_LENGTH}; Names: ${_vcpkg_find_lib_NAMES}!")
        endif()
        vcpkg_msg(STATUS "find_library" "Added NAMES_PER_DIR to find_library call at position ${_vcpkg_find_lib_NAMES_LENGTH}!")
    endif()
    vcpkg_msg(STATUS "find_library-vars" "${_vcpkg_list_vars}")
    
    #Actual find_library call with fixed argument list!
    _find_library(${_vcpkg_list_vars})
    
    # Check found Library variable:
    # If NOTFOUND means:
    # a) it really cannot be found 
    # b) the search names are wrong in vcpkg because:
    #       1. a debug suffix is missing in the library name
    #    or 2. or a debug suffix was added to the library name
    #
    # If FOUND: 
    # 1. Check if path is prefixed with ${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET} . If not return early
    # 2. check if variable has _RELEASE or _DEBUG name suffix
    #   a) If yes check correctnes of path
    #   b) if _RELEASE variable points to debug path -> release lib name == debug lib name -> adjust path
    #       1. memorize lib name
    #       2. create internal cache varibles with the lib name.
    #   c) if _DEBUG variable points to release path -> missing debug suffix in library name -> try search without common debugsuffixes -> if found everything is fine
    #       1. memorize lib name without debug suffix
    #       2. create internal cache varibles with the lib name.
    #   d) no special variable suffix
    #       1. check path -> should be release path if not adjust it
    #       2. memorize lib name
    #       3. create internal cache variables with the lib name 
    
    if("${${_vcpkg_find_library_imp_output}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}")

        vcpkg_msg(STATUS "find_library" "Found library inside vcpkg: ${_vcpkg_find_library_imp_output}:${${_vcpkg_find_library_imp_output}}")
        vcpkg_msg(STATUS "find_library" "Search names: ${_vcpkg_find_lib_NAMES}")
        #Here we know that the library somehow exists in the vcpkg folder and the user asked for it. So lets try to discover the vcpkg debug and release versions in a very controlled way. 
        if(_vcpkg_find_lib_PATH_SUFFIXES)
            vcpkg_search_library_debug(_vcpkg_debug_lib_path NAMES ${_vcpkg_find_lib_NAMES} PATH_SUFFIXES ${_vcpkg_find_lib_PATH_SUFFIXES})
            vcpkg_search_library_release(_vcpkg_release_lib_path NAMES ${_vcpkg_find_lib_NAMES} PATH_SUFFIXES ${_vcpkg_find_lib_PATH_SUFFIXES})
        else()
            vcpkg_search_library_debug(_vcpkg_debug_lib_path NAMES ${_vcpkg_find_lib_NAMES} PATH_SUFFIXES "")
            vcpkg_search_library_release(_vcpkg_release_lib_path NAMES ${_vcpkg_find_lib_NAMES} PATH_SUFFIXES "")
        endif()
        
        vcpkg_msg(STATUS "find_library" "VCPKG internal debug lib path: ${_vcpkg_debug_lib_path}")
        vcpkg_msg(STATUS "find_library" "VCPKG internal release lib path:: ${_vcpkg_release_lib_path}")
        
        if("${_vcpkg_find_library_imp_output}" MATCHES "_DEBUG$|_DBG$")
            set(${_vcpkg_find_library_imp_output} ${_vcpkg_debug_lib_path} CACHE INTERNAL "")
			set(${_vcpkg_find_library_imp_output} ${_vcpkg_debug_lib_path} PARENT_SCOPE)
        elseif("${_vcpkg_find_library_imp_output}" MATCHES "_RELEASE$|_REL$")
            if(${_vcpkg_release_lib_path} MATCHES "NOTFOUND") # Release must be found. 
                cmake_policy(POP)
                vcpkg_msg(FATAL_ERROR "find_library" "Unable to find release library within vcpkg. Release library must always be found! \
                                                      variable: ${_vcpkg_find_library_imp_output} search names: ${_vcpkg_find_lib_NAMES}")
            endif()
           set(${_vcpkg_find_library_imp_output} ${_vcpkg_release_lib_path} CACHE INTERNAL "")
		   set(${_vcpkg_find_library_imp_output} ${_vcpkg_release_lib_path} PARENT_SCOPE) 
        else() #these are the cases which are ambigous! Sometimes also used as synonym for the release version
            if(CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$")
                set(${_vcpkg_find_library_imp_output} ${_vcpkg_debug_lib_path} CACHE INTERNAL "")
				set(${_vcpkg_find_library_imp_output} ${_vcpkg_debug_lib_path} PARENT_SCOPE)
                if(${_vcpkg_debug_lib_path} MATCHES "NOTFOUND") # If only release was build we use that instead!
                    cmake_policy(POP)
                    vcpkg_msg(FATAL_ERROR "find_library" "Build type is debug but vcpkg was unable to find the debug library. \
                                           variable: ${_vcpkg_find_library_imp_output} search names: ${_vcpkg_find_lib_NAMES}")
                    set(${_vcpkg_find_library_imp_output} ${_vcpkg_release_lib_path} CACHE INTERNAL "")
					set(${_vcpkg_find_library_imp_output} ${_vcpkg_release_lib_path} PARENT_SCOPE) 
                endif()
            else() # Not debug and multi config generator
                set(${_vcpkg_find_library_imp_output} ${_vcpkg_release_lib_path} CACHE INTERNAL "") 
				set(${_vcpkg_find_library_imp_output} ${_vcpkg_release_lib_path} PARENT_SCOPE) 
                # For a multi configuration generator this selection might be wrong and there is no way to change it here because
                # it is unknown in which way the value might be used. Injecting a configuration dependent generator expressions here 
                # does not work everywhere (e.g. try_compile or func_exists checks) and also injecting debug/optimized keywords here does not work. 
                # So we need VCPKG_LIBTRACK to check/fix other places e.g. the IMPORTED_LOCATION in generated targets via set_property and set_target_properties 
                # and the calls to link_libraries and target_link_libraries
            endif()
        endif()           
    elseif("${${_vcpkg_find_library_imp_output}}" MATCHES "NOTFOUND")
        if("${_vcpkg_find_library_imp_output}" MATCHES "_DEBUG" AND VCPKG_DEBUG_AVAILABLE) #Retry search (probably requires a search without common debug suffixes)
            vcpkg_search_library_debug(_vcpkg_debug_lib_path NAMES "${_vcpkg_find_lib_NAMES}" PATH_SUFFIXES "${_vcpkg_find_lib_PATH_SUFFIXES}")
            if(${_vcpkg_debug_lib_path})
                vcpkg_search_library_release(_vcpkg_release_lib_path NAMES ${_vcpkg_find_lib_NAMES} PATH_SUFFIXES ${_vcpkg_find_lib_PATH_SUFFIXES})
                set(${_vcpkg_find_library_imp_output} ${_vcpkg_debug_lib_path} CACHE INTERNAL "")
				set(${_vcpkg_find_library_imp_output} ${_vcpkg_debug_lib_path} PARENT_SCOPE)
            endif()
        else()
            vcpkg_msg(STATUS "find_library" "${_vcpkg_find_library_imp_output} was not found!")
        endif()        
    else()
        #found library outside vcpkg
        vcpkg_msg(STATUS "find_library" "Found external library: ${_vcpkg_find_library_imp_output}:${${_vcpkg_find_library_imp_output}}")
    endif()  

    ##Setup VCPKG_LIBTRACK
    ##Assumptions: _vcpkg_debug_lib_path and _vcpkg_release_lib_path are setup correctly (which should be the case if either one could be found)
    ##Note: The only thing we have is a list of search names and the filename for usage. So we use the filename to create a redirection to a variable using the found search name
    ##The Release library must always exist!
    if(NOT "${${_vcpkg_find_library_imp_output}}" MATCHES "NOTFOUND")
        vcpkg_msg(STATUS "find_library" "*** Setting up VCPKG LIBTRACK ***")
        if(NOT ${_vcpkg_release_lib_path} MATCHES "NOTFOUND")        
            vcpkg_extract_library_name_from_path(_vcpkg_rel_lib_name ${_vcpkg_release_lib_path})
            set(VCPKG_LIBTRACK_${_vcpkg_rel_lib_name}_RELEASE ${_vcpkg_release_lib_path} CACHE INTERNAL "" )
            vcpkg_msg(STATUS "find_library" "Setting VCPKG_LIBTRACK_${_vcpkg_rel_lib_name}_RELEASE: ${VCPKG_LIBTRACK_${_vcpkg_rel_lib_name}_RELEASE}")
            set(VCPKG_LIBTRACK_RELEASE ON)
        endif()
        if(NOT ${_vcpkg_debug_lib_path} MATCHES "NOTFOUND")
            vcpkg_extract_library_name_from_path(_vcpkg_dbg_lib_name ${_vcpkg_debug_lib_path})
            set(VCPKG_LIBTRACK_${_vcpkg_dbg_lib_name}_DEBUG ${_vcpkg_debug_lib_path} CACHE INTERNAL "" )
            vcpkg_msg(STATUS "find_library" "Setting VCPKG_LIBTRACK_${_vcpkg_dbg_lib_name}_DEBUG: ${VCPKG_LIBTRACK_${_vcpkg_dbg_lib_name}_DEBUG}")
            set(VCPKG_LIBTRACK_DEBUG ON)
        endif()
        if(VCPKG_LIBTRACK_RELEASE AND VCPKG_LIBTRACK_DEBUG)
            vcpkg_msg(STATUS "find_library" "Setting up VCPKG LIBTRACK RELEASE/DEBUG")
            set(VCPKG_LIBTRACK_${_vcpkg_rel_lib_name}_DEBUG ${_vcpkg_debug_lib_path} CACHE INTERNAL "" )
            vcpkg_msg(STATUS "find_library" "Setting VCPKG_LIBTRACK_${_vcpkg_rel_lib_name}_DEBUG: ${VCPKG_LIBTRACK_${_vcpkg_rel_lib_name}_DEBUG}")
            set(VCPKG_LIBTRACK_${_vcpkg_dbg_lib_name}_RELEASE ${_vcpkg_release_lib_path} CACHE INTERNAL "" )
            vcpkg_msg(STATUS "find_library" "Setting VCPKG_LIBTRACK_${_vcpkg_dbg_lib_name}_RELEASE: ${VCPKG_LIBTRACK_${_vcpkg_dbg_lib_name}_RELEASE}")
        endif()
    endif()

    cmake_policy(POP)
endfunction()

if(VCPKG_ENABLE_find_library)
    function(find_library _vcpkg_find_library_var_name)
        vcpkg_enable_function_overwrite_guard(find_library "")

        vcpkg_find_library(${_vcpkg_find_library_var_name} ${ARGN})
        set(${_vcpkg_find_library_var_name} "${${_vcpkg_find_library_var_name}}" PARENT_SCOPE) #Propagate the variable into the parent scope!
        
        vcpkg_disable_function_overwrite_guard(find_library "")
    endfunction()
endif(VCPKG_ENABLE_find_library)