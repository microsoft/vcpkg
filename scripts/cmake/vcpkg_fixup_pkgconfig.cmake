#.rst:
# .. command:: vcpkg_fixup_pkgconfig
#
# Tries to fix the paths found in *.pc files

function(vcpkg_fixup_pkgconfig)
    cmake_parse_arguments(_vfpkg "" "" "RELEASE_FILES;DEBUG_FILES" ${ARGN})

    if(_vfpkg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_fixup_pkgconfig was passed extra arguments: ${_vfct_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT _vfpkg_RELEASE_FILES)
        file(GLOB_RECURSE _vfpkg_RELEASE_FILES **/*.pc)
        list(FILTER _vfpkg_RELEASE_FILES EXCLUDE REGEX "${CURRENT_PACKAGES_DIR}/debug/")
    endif()
    
    if(NOT _vfct_DEBUG_FILES)
        file(GLOB_RECURSE _vfct_DEBUG_FILES **/*.pc)
        list(FILTER _vfct_DEBUG_FILES INCLUDE REGEX "${CURRENT_PACKAGES_DIR}/debug/")
    endif()

    foreach(_file ${_vfpkg_RELEASE_FILES})
        file(READ "${_file}" _contents)
        string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        
        string(REPLACE "prefix=\${prefix}" "${CURRENT_INSTALLED_DIR}" _contents "${_contents}")
        file(WRITE "${_file}" "${_contents}")
    endforeach()
    
        foreach(_file ${_vfct_DEBUG_FILES})
        file(READ "${_file}" _contents)
        string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "debug/include" "../include" _contents "${_contents}")
        string(REPLACE "debug/share" "../share" _contents "${_contents}")
        string(REPLACE "prefix=\${prefix}" "${CURRENT_INSTALLED_DIR}" _contents "${_contents}")
        file(WRITE "${_file}" "${_contents}")
    endforeach()
endfunction()

 
