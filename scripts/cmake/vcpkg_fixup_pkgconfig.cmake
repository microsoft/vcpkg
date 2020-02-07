## # vcpkg_fixup_pkgconfig
##
## Fix common paths in *.pc files and make everything relativ to $(prefix)
##
## ## Usage
## ```cmake
## vcpkg_fixup_pkgconfig(
##     [RELEASE_FILES <PATHS>...]
##     [DEBUG_FILES <PATHS>...]
## )
## ```
##
## ## Parameters
## ### RELEASE_FILES
## Specifies a list of files to apply the fixes for release paths. 
## Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR} without ${CURRENT_PACKAGES_DIR}/debug/
##
## ### RELEASE_FILES
## Specifies a list of files to apply the fixes for debug paths.
## Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR}/debug/
##
## ## Notes
## Still work in progress. If there are more cases which can be handled here feel free to add them
##
## ## Examples
##
## Just call vcpkg_fixup_pkgconfig() after any install step which installs *.pc files. 


function(vcpkg_fixup_pkgconfig)
    cmake_parse_arguments(_vfpkg "" "" "RELEASE_FILES;DEBUG_FILES" ${ARGN})
    
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
        file(WRITE "${_file}" "${_contents}")
    endforeach()
    message(STATUS "Fixing pkgconfig --- finished")
endfunction()

 
