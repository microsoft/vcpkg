#.rst:
# .. command:: vcpkg_fixup_pkgconfig
#
# Tries to fix the paths found in *.pc files

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
    message(STATUS "Files: ${_vfpkg_RELEASE_FILES}")
    foreach(_file ${_vfpkg_RELEASE_FILES})
        file(READ "${_file}" _contents)
        string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" _contents "${_contents}")
        string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" _contents "${_contents}")
        string(REGEX REPLACE "^prefix=\\\${prefix}" "#prefix=${CURRENT_INSTALLED_DIR}" _contents "${_contents}") # Comment out prefix
        file(WRITE "${_file}" "${_contents}")
    endforeach()
    
    message(STATUS "Fixing pkgconfig - debug")
    message(STATUS "Files: ${_vfpkg_DEBUG_FILES}")
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

 
