# A word about find_library and vcpkg
# In single configuration generators vcpkg will fix CMAKE_PREFIX_PATH and other variables to correctly search for libraries
# In a multi configuration generator vcpkg there can only be one CMAKE_PREFIX_PATH so we have to correct all find_library calls


function(find_library _vcpkg_lib_var)
    set(_vcpkg_list_vars "${ARGV}")
    set(options NAMES_PER_DIR 
                NO_DEFAULT_PATH 
                NO_PACKAGE_ROOT_PATH 
                NO_CMAKE_PATH 
                NO_CMAKE_ENVIRONMENT_PATH 
                NO_SYSTEM_ENVIRONMENT_PATH 
                NO_CMAKE_SYSTEM_PATHCMAKE_FIND_ROOT_PATH_BOTH 
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
    endif()
    if(NOT _vcpkg_find_lib_NAMES_PER_DIR) #Insert NAMES_PER_DIR if not set!
        list(LENGTH _vcpkg_find_lib_NAMES _vcpkg_find_lib_NAMES_LENGTH)
        #set(_vcpkg_find_lib_NAMES_LENGTH ${_vcpkg_find_lib_NAMES_LENGTH})
        list(INSERT _vcpkg_list_vars ${_vcpkg_find_lib_NAMES_LENGTH} NAMES_PER_DIR)
        message(STATUS "VCPKG-find_library: Added NAMES_PER_DIR to find_library call at ${_vcpkg_find_lib_NAMES_LENGTH}!")
    endif()
    message(STATUS "VCPKG-find_library-vars:${_vcpkg_list_vars}!")
    _find_library(${_vcpkg_list_vars})
    if(NOT "${${_vcpkg_lib_var}}" MATCHES "NOTFOUND") #Library was found
        message(STATUS "VCPKG-find_library: ${_vcpkg_lib_var}:${${_vcpkg_lib_var}}")
        if("${${_vcpkg_lib_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}") #Check if within vcpkg folder/if not not our concern
            if("${_vcpkg_lib_var}" MATCHES "_DEBUG")
                if(NOT "${${_vcpkg_lib_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib")
                    message(FATAL_ERROR "VCPKG-error-find_library: ${_vcpkg_lib_var}:${${_vcpkg_lib_var}} does not point to debug directory!")
                endif()
            elseif("${_vcpkg_lib_var}" MATCHES "_RELEASE")
                if(NOT "${${_vcpkg_lib_var}}" MATCHES "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib")
                    message(FATAL_ERROR "VCPKG-error-find_library: ${_vcpkg_lib_var}:${${_vcpkg_lib_var}} does not point to release directory!")
                endif()
            else() #these are the cases we probably need to correct!
                #Extract names of the library
                if(${ARGV1} MATCHES NAMES)
                    set(_vcpkg_lib_names ${ARGV2})
                else()
                    set(_vcpkg_lib_names ${ARGV1})
                endif()
            endif()
        endif()
    else()
        message(STATUS "VCPKG-find_library: ${_vcpkg_lib_var} was not found!")
    endif()
endfunction()