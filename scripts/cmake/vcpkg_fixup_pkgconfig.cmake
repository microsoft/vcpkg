## # vcpkg_fixup_pkgconfig
##
## Fix common paths in *.pc files and make everything relativ to $(prefix)
##
## ## Usage
## ```cmake
## vcpkg_fixup_pkgconfig(
##     [RELEASE_FILES <PATHS>...]
##     [DEBUG_FILES <PATHS>...]
##     [SYSTEM_LIBRARIES <NAMES>...]
## )
## ```
##
## ## Parameters
## ### RELEASE_FILES
## Specifies a list of files to apply the fixes for release paths. 
## Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR} without ${CURRENT_PACKAGES_DIR}/debug/
##
## ### DEBUG_FILES
## Specifies a list of files to apply the fixes for debug paths.
## Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR}/debug/
##
## ### SYSTEM_PACKAGES
## If the *.pc file contains system packages outside vcpkg these need to be listed here.
## Since vcpkg checks the existence of all required packages within vcpkg. 
##
## ### SYSTEM_LIBRARIES
## If the *.pc file contains system libraries outside vcpkg these need to be listed here.
## VCPKG checks every -l flag for the existence of the required library within vcpkg. 
##
## ## Notes
## Still work in progress. If there are more cases which can be handled here feel free to add them
##
## ## Examples
##
## Just call vcpkg_fixup_pkgconfig() after any install step which installs *.pc files. 

function(vcpkg_fixup_pkgconfig_find_library _pc_contents)

endfunction()

function(vcpkg_fixup_pkgconfig_check_libraries _config _contents_var _system_libs)
    message(STATUS "Checking configuration: ${_config}")
    if(_config STREQUAL "DEBUG")
        set(prefix "${CURRENT_INSTALLED_DIR}/debug/")
        set(lib_suffixes d _d _debug)
    else()
        set(prefix "${CURRENT_INSTALLED_DIR}/lib")
        set(lib_suffixes "")
    endif()
    set(_contents "${${_contents_var}}")
    message(STATUS "Contents: ${_contents}")
    set(_system_lib_normalized)
    foreach(_system_lib ${_system_libs})
        string(REPLACE "-l" "" _system_lib "${_system_lib}")
        list(APPEND _system_lib_normalized "${_system_lib}")
    endforeach()
    
    ## Extra libraries:
    string(REGEX MATCH "Libs:[^\n]+\n" _libs "${_contents}")
    message(STATUS "LIB LINE: ${_libs}")
    # The path to the library is either quoted and can not contain a quote or it is unqouted and cannot contain a single unescaped space
    string(REGEX REPLACE "([\t ])-(l|L)((\\\"[^\\\"]+\\\"|([^ ]|\\ )+))" ";\\2\\3" _libs_list_tmp "${_libs}")
    string(REGEX MATCH "Libs.private:[^\n]+\n" _libs_private "${_contents}")
    string(REGEX MATCHALL "([\t ]-(l|L)(\"[^\"]+\"|([^ ]|\\ )+))+" _libs_private_list_tmp "${_libs_private}")
    message(STATUS "Found libraries: ${_libs_list_tmp}")
    message(STATUS "Found private libraries: ${_libs_private_list_tmp}")
    
    
    ## Packages:
    string(REGEX MATCH "Requires:[^\n]+\n" _pkg "${_contents}")
    string(REGEX MATCHALL "([\t ][^\t ]+)+" _pkg_list_tmp "${_pkg}")
    string(REGEX MATCH "Requires.private:[^\n]+\n" _pkg_private "${_contents}")
    string(REGEX MATCHALL "([\t ][^\t ]+)+" _pkg_private_list_tmp "${_pkg_private}")
    message(STATUS "Found required packages: ${_pkg_list_tmp}")
    message(STATUS "Found private required packages: ${_pkg_private_list_tmp}")
    ## Push modifications up in scope
    set(${_contents_var} "${_contents}" PARENT_SCOPE)
endfunction()

function(vcpkg_fixup_pkgconfig)
    cmake_parse_arguments(_vfpkg "" "" "RELEASE_FILES;DEBUG_FILES;SYSTEM_LIBRARIES" ${ARGN})
    
    message(STATUS "Fixing pkgconfig")
    if(_vfpkg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_pkgconfig was passed extra arguments: ${_vfct_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT _vfpkg_RELEASE_FILES)
        file(GLOB_RECURSE _vfpkg_RELEASE_FILES "${CURRENT_PACKAGES_DIR}/**/*.pc")
        list(FILTER _vfpkg_RELEASE_FILES EXCLUDE REGEX "${CURRENT_PACKAGES_DIR}/debug/")
    endif()
    
    if(NOT _vfpkg_DEBUG_FILES)
        file(GLOB_RECURSE _vfpkg_DEBUG_FILES "${CURRENT_PACKAGES_DIR}/debug/**/*.pc")
        list(FILTER _vfpkg_DEBUG_FILES INCLUDE REGEX "${CURRENT_PACKAGES_DIR}/debug/")
    endif()
    
    message(STATUS "Fixing pkgconfig - release")
    debug_message("Files: ${_vfpkg_RELEASE_FILES}")
    foreach(_file ${_vfpkg_RELEASE_FILES})
        file(READ "${_file}" _contents)
        string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        string(REGEX REPLACE "^prefix=\\\${prefix}" "#prefix=${CURRENT_INSTALLED_DIR}" _contents "${_contents}") # Comment out prefix
        vcpkg_fixup_pkgconfig_check_libraries("RELEASE" _contents "${_vfpkg_SYSTEM_LIBRARIES}")
        file(WRITE "${_file}" "${_contents}")
    endforeach()
    
    message(STATUS "Fixing pkgconfig - debug")
    debug_message("Files: ${_vfpkg_DEBUG_FILES}")
    foreach(_file ${_vfpkg_DEBUG_FILES})
        file(READ "${_file}" _contents)
        string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        
        string(REPLACE "debug/include" "../include" _contents "${_contents}")
        string(REPLACE "\${prefix}/include" "\${prefix}/../include" _contents "${_contents}")
        
        string(REPLACE "debug/share" "../share" _contents "${_contents}")
        string(REPLACE "\${prefix}/share" "\${prefix}/../share" _contents "${_contents}")
        
        string(REPLACE "debug/lib" "lib" _contents "${_contents}") # the prefix will contain the debug keyword
        string(REGEX REPLACE "^prefix=\\\${prefix}/debug" "#prefix=${CURRENT_INSTALLED_DIR}/debug" _contents "${_contents}") # Comment out prefix
        string(REPLACE "${prefix}/debug" "\${prefix}" _contents "${_contents}") # replace remaining debug paths if they exist. 
        vcpkg_fixup_pkgconfig_check_libraries("RELEASE" _contents "${_vfpkg_SYSTEM_LIBRARIES}")
        file(WRITE "${_file}" "${_contents}")
    endforeach()
    message(STATUS "Fixing pkgconfig --- finished")
endfunction()

 
