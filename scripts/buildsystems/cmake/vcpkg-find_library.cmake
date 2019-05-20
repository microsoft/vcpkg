# A word about find_library and vcpkg
# In single configuration generators vcpkg will fix CMAKE_PREFIX_PATH and other variables to correctly search for libraries
# In a multi configuration generator vcpkg there can only be one CMAKE_PREFIX_PATH so we have to correct all find_library calls
# If the library variable is called either _RELEASE or _DEBUG there must be a way to distingush between debug/release version of a library by name (so no change required here)

#NOt used Yet
option(VCPKG_ONLY_VCPKG_LIBS "Disallows find_library calls to search outside of the vcpkg directory" OFF)
mark_as_advanced(VCPKG_ONLY_VCPKG_LIBS)

option(VCPKG_ENABLE_FIND_LIBRARY "Enables override of the cmake function find_library." ON)
mark_as_advanced(VCPKG_ENABLE_FIND_LIBRARY)
CMAKE_DEPENDENT_OPTION(VCPKG_ENABLE_FIND_LIBRARY_EXTERNAL_OVERRIDE "Tells VCPKG to use _find_library instead of find_library." OFF "NOT VCPKG_ENABLE_FIND_LIBRARY" OFF)
mark_as_advanced(VCPKG_ENABLE_FIND_LIBRARY_EXTERNAL_OVERRIDE)

#Setup common debug suffix used by ports;
set(VCPKG_ADDITIONAL_DEBUG_LIBNAME_SEARCH_SUFFIXES "d;_d;_debug")
mark_as_advanced(VCPKG_ADDITIONAL_DEBUG_LIBNAME_SEARCH_SUFFIXES)

function(vcpkg_find_library _vcpkg_lib_var)
    cmake_policy(PUSH)
    cmake_policy(SET CMP0054 NEW)
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
    cmake_parse_arguments(PARSE_ARGV 1 _vcpkg_find_lib "${options}" "${oneValueArgs}" "${multiValueArgs}")
    if(NOT DEFINED _vcpkg_find_lib_NAMES)
        set(_vcpkg_find_lib_NAMES ${ARGV1})
        set(_insert_offset 1)
    else()
        set(_insert_offset 2)
    endif()
    if(NOT _vcpkg_find_lib_NAMES_PER_DIR) #Insert NAMES_PER_DIR if not set!
        list(LENGTH _vcpkg_find_lib_NAMES _vcpkg_find_lib_NAMES_LENGTH)
        math(EXPR _insert_pos "${_vcpkg_find_lib_NAMES_LENGTH}+${_insert_offset}" OUTPUT_FORMAT DECIMAL)
        list(INSERT _vcpkg_list_vars ${_insert_pos} NAMES_PER_DIR)
        vcpkg_msg(STATUS "find_library" "Added NAMES_PER_DIR to find_library call at position ${_vcpkg_find_lib_NAMES_LENGTH}!")
    endif()
    vcpkg_msg(STATUS "find_library-vars" "${_vcpkg_list_vars}")
    if(VCPKG_ENABLE_FIND_LIBRARY OR VCPKG_ENABLE_FIND_LIBRARY_EXTERNAL_OVERRIDE)
        _find_library(${_vcpkg_list_vars})
    else()
        find_library(${_vcpkg_list_vars})
    endif()
    if(NOT "${${_vcpkg_lib_var}}" MATCHES "NOTFOUND") #Library was found
        message(STATUS "VCPKG-find_library: ${_vcpkg_lib_var}:${${_vcpkg_lib_var}}")
        if("${${_vcpkg_lib_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}") 
        #Check if within vcpkg folder/if not not our concern
        #This is the first barrier of defense against wrong configuration linkage
            if("${_vcpkg_lib_var}" MATCHES "_DEBUG")
                if(NOT "${${_vcpkg_lib_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib")
                    #This probably means that the find module assumes a wrong name for the debug library
                    cmake_policy(POP)
                    vcpkg_msg(FATAL_ERROR "find_library" "${_vcpkg_lib_var}:${${_vcpkg_lib_var}} does not point to debug directory! Check library debug naming! NAMES: ${_vcpkg_find_lib_NAMES}" ALWAYS)
                endif()
            elseif("${_vcpkg_lib_var}" MATCHES "_RELEASE")
                if("${${_vcpkg_lib_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib")
                    #This probably means that debug name = release name so we search only in the release lib path!
                    vcpkg_msg(STATUS "find_library" "${_vcpkg_lib_var}:${${_vcpkg_lib_var}} does not point to release directory! This probably means that debug name = release name!: NAMES: ${_vcpkg_find_lib_NAMES}")
                    if(NOT DEFINED _vcpkg_find_lib_PATH_SUFFIXES)
                        set(_vcpkg_path_search_list "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib")
                        list(APPEND _vcpkg_path_search_list "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/manual-link")
                    else()
                        list(FILTER _vcpkg_find_lib_PATH_SUFFIXES EXCLUDE REGEX "[Dd][Ee][Bb][Uu][Gg]/")
                        foreach(_vcpkg_path_prefix ${_vcpkg_path_search_list})
                            foreach(_path_suffix ${_vcpkg_find_lib_PATH_SUFFIXES})
                                list(APPEND _path_search_list "${_vcpkg_path_prefix}/${_path_suffix}")
                                list(APPEND _path_search_list "${_vcpkg_path_prefix}/${_path_suffix}")
                            endforeach()
                        endforeach()
                    endif()
                    vcpkg_msg(STATUS "find_library" "Searching for release library with paths: ${_path_search_list}")
                    unset(_tmp_${_vcpkg_lib_var})
                    if(VCPKG_ENABLE_FIND_LIBRARY OR VCPKG_ENABLE_FIND_LIBRARY_EXTERNAL_OVERRIDE)
                        _find_library(_tmp_${_vcpkg_lib_var} NAMES ${_vcpkg_find_lib_NAMES} NAMES_PER_DIR 
                                        PATHS ${_path_search_list} NO_DEFAULT_PATH)
                    else()
                        find_library(_tmp_${_vcpkg_lib_var} NAMES ${_vcpkg_find_lib_NAMES} NAMES_PER_DIR 
                                        PATHS ${_path_search_list} NO_DEFAULT_PATH)
                    endif()
                    #if("${_tmp_${_vcpkg_lib_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib") # check if we are still 
                    #    cmake_policy(POP)
                    #    vcpkg_msg(FATAL_ERROR "find_library" "${_vcpkg_lib_var}:${${_vcpkg_lib_var}} Unable to locate release library! NAMES: ${_vcpkg_find_lib_NAMES}")
                    #endif()
                    set(${_vcpkg_lib_var} "${_tmp_${_vcpkg_lib_var}}" PARENT_SCOPE) #Cannot be directly set since CMake will CACHE the previous result
                    vcpkg_msg(STATUS "find_library" "${_vcpkg_lib_var} after ${${_vcpkg_lib_var}}")
                endif()
            else() #these are the cases we need to correct!
                if("${${_vcpkg_lib_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/" AND EXISTS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug") # the and makes sure that debug was actually build
                    #TODO: add a search for _d and d suffixed libraries for ports that did not get the memo of #6014. If not succesful -> FATAL_ERROR
                    vcpkg_msg(WARNING "find_library" " ${_vcpkg_lib_var} not pointing to expected debug path. Trying to find library with common debug suffixes!")
                    foreach(_vcpkg_debug_suffix ${VCPKG_ADDITIONAL_DEBUG_LIBNAME_SEARCH_SUFFIXES})
                        foreach(_vcpkg_lib_name ${_vcpkg_find_lib_NAMES})
                            list(APPEND _vcpkg_debug_lib_names_${_vcpkg_debug_suffix} "${_vcpkg_lib_name}${_vcpkg_debug_suffix}")
                        endforeach()
                        string(REGEX REPLACE "${_vcpkg_find_lib_NAMES};NAMES_PER_DIR" "${_vcpkg_debug_lib_names_${_vcpkg_debug_suffix}};NAMES_PER_DIR" _vcpkg_list_vars_debug "${_vcpkg_list_vars}") 
                        # We added NAMES_PER_DIR; This is a guard to not change the variable name in the list (first entry)
                        string(REGEX REPLACE "^${_vcpkg_lib_var}" "${_vcpkg_lib_var}_suffix_${_vcpkg_debug_suffix}" _vcpkg_list_vars_debug "${_vcpkg_list_vars_debug}") #New variable name
                        vcpkg_msg(STATUS "find_library" "Debug call vars: ${_vcpkg_list_vars_debug}")
                        if(VCPKG_ENABLE_FIND_LIBRARY OR VCPKG_ENABLE_FIND_LIBRARY_EXTERNAL_OVERRIDE)
                            _find_library(${_vcpkg_list_vars_debug})
                        else()
                            find_library(${_vcpkg_list_vars_debug})
                        endif()
                        vcpkg_msg(STATUS "find_library" "Debug var ${_vcpkg_lib_var}_suffix_${_vcpkg_debug_suffix}: ${${_vcpkg_lib_var}_suffix_${_vcpkg_debug_suffix}}")
                        if("${${_vcpkg_lib_var}_suffix_${_vcpkg_debug_suffix}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib")
                            #found the debug library!
                            #release path is in: ${_vcpkg_lib_var}
                            #debug path is in: _tmp_${_vcpkg_lib_var}
                            #To create the generator expressions we first need to know the original library name!
                            unset(_vcpkg_lib_found_name)
                            unset(_vcpkg_lib_found_name_index)
                            foreach(_vcpkg_lib_name ${_vcpkg_find_lib_NAMES})
                                vcpkg_msg(STATUS "find_library" "Name ${_vcpkg_lib_name} searched in ${${_vcpkg_lib_var}}")
                                string(FIND "${${_vcpkg_lib_var}}" "${_vcpkg_lib_name}" _vcpkg_lib_found_name_index)
                                #vcpkg_msg(STATUS "find_library" "INDEX: ${_vcpkg_lib_found_name_index} searched in ${${_vcpkg_lib_var}}")
                                if(NOT ${_vcpkg_lib_found_name_index} EQUAL -1)
                                     vcpkg_msg(STATUS "find_library" "Name ${_vcpkg_lib_name} found in ${${_vcpkg_lib_var}}")
                                    set(_vcpkg_lib_found_name "${_vcpkg_lib_name}")
                                    break()
                                else()
                                    vcpkg_msg(STATUS "find_library" "Name ${_vcpkg_lib_name} not found in ${${_vcpkg_lib_var}}")
                                endif()
                            endforeach()
                            if("${${_vcpkg_lib_var}_suffix_${_vcpkg_debug_suffix}}" MATCHES "${_vcpkg_lib_found_name}")
                                vcpkg_msg(STATUS "find_library" "${_vcpkg_lib_var} before ${${_vcpkg_lib_var}}")
                                string(REGEX REPLACE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/\$<\$<CONFIG:DEBUG>:debug/>" ${_vcpkg_lib_var} "${${_vcpkg_lib_var}}")
                                string(REGEX REPLACE "${_vcpkg_lib_found_name}" "${_vcpkg_lib_found_name}\$<\$<CONFIG:DEBUG>:${_vcpkg_debug_suffix}>" ${_vcpkg_lib_var} "${${_vcpkg_lib_var}}")
                                vcpkg_msg(STATUS "find_library" "${_vcpkg_lib_var} after ${${_vcpkg_lib_var}}")
                                cmake_policy(POP)
                                return()
                            else()
                                #Logically this should never trigger expect the port does something really strange in the naming of debug builds (like using a totally different name)!
                                vcpkg_msg(WARNING "find_library" "${_vcpkg_lib_found_name} not found in ${${_vcpkg_lib_var}_suffix_${_vcpkg_debug_suffix}}. Check library name!")
                            endif()
                        endif()
                    endforeach()
                    #if(NOT ${${_vcpkg_lib_var}} MATCHES "<CONFIG:DEBUG>:debug/") #Death case. Means ${_vcpkg_lib_var} was not changed by us and still points to release directory
                    #Nothing found -> so configure should die
                    cmake_policy(POP)
                    vcpkg_msg(FATAL_ERROR "find_library" "${_vcpkg_lib_var}:${${_vcpkg_lib_var}} does not point to debug directory as expected! \
                                                            Check library debug/release naming!: NAMES: ${_vcpkg_find_lib_NAMES}" ALWAYS)
                    #endif()
                else()
                    vcpkg_msg(STATUS "find_library" "${_vcpkg_lib_var} before ${${_vcpkg_lib_var}}")
                    string(REGEX REPLACE "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/" "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/\$<\$<CONFIG:DEBUG>:debug/>" ${_vcpkg_lib_var} "${${_vcpkg_lib_var}}")
                    set(${_vcpkg_lib_var} "${${_vcpkg_lib_var}}" PARENT_SCOPE) #Need to promote change to parant scope
                    vcpkg_msg(STATUS "find_library" "${_vcpkg_lib_var} after ${${_vcpkg_lib_var}}")
                endif()
            endif()
        endif()
    else()
        vcpkg_msg(STATUS "find_library" "${_vcpkg_lib_var} was not found!")
    endif()
    cmake_policy(POP)
endfunction()

if(VCPKG_ENABLE_FIND_LIBRARY)
    function(find_library name)
        if(DEFINED _vcpkg_find_library_guard_${name})
            vcpkg_msg(FATAL_ERROR "find_library" "INFINIT LOOP DETECT. Did you supply your own find_library override? \n \
                                    If yes: please set VCPKG_ENABLE_FIND_LIBRARY off and call vcpkg_find_library if you want to have vcpkg corrected behavior. \n \
                                    If no: please open an issue on GITHUB describe the fail case!" ALWAYS)
        else()
            set(_vcpkg_find_library_guard_${name} ON)
        endif()
        vcpkg_find_library(${ARGV})
        unset(_vcpkg_find_library_guard_${name})
    endfunction()
endif(VCPKG_ENABLE_FIND_LIBRARY)