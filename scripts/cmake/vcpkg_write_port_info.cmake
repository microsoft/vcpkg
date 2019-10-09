## # vcpkg_write_port_info
##
## write useful port information into share/${PORT}/vcpkg_port_info.cmake
## these file contain
## ${PORT}_LIBRARIES_(RELEASE|DEBUG)        libraries installed by PORT
## ${PORT}_DEPENDENCIES                     list of PORT dependencies as port names
## ${PORT}_FEATURES                         list of PORT installed features
##
## ```
##
function(vcpkg_write_port_info)
    set(info_file ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg_port_info.cmake)
    
    file(GLOB_RECURSE ${PORT}_LIBRARIES_RELEASE "${CURRENT_PACKAGES_DIR}/lib/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    file(GLOB_RECURSE ${PORT}_LIBRARIES_DEBUG "${CURRENT_PACKAGES_DIR}/debug/lib/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    
    string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${CURRENT_INSTALLED_DIR}" ${PORT}_LIBRARIES_RELEASE "${${PORT}_LIBRARIES_RELEASE}")
    string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${CURRENT_INSTALLED_DIR}" ${PORT}_LIBRARIES_DEBUG "${${PORT}_LIBRARIES_DEBUG}")
    
    file(WRITE "${info_file}" "set(${PORT}_LIBRARIES_RELEASE \"${${PORT}_LIBRARIES_RELEASE}\" CACHE INTERNAL \"\") \n")
    file(APPEND "${info_file}" "set(${PORT}_LIBRARIES_DEBUG \"${${PORT}_LIBRARIES_DEBUG}\" CACHE INTERNAL \"\")\n")
    file(APPEND "${info_file}" "set(${PORT}_FEATURES ${FEATURES} CACHE INTERNAL \"\")\n")
    
    vcpkg_get_build_depends(OUTPUT_VARIABLE ${PORT}_DEPENDENCIES)
    file(APPEND "${info_file}" "set(${PORT}_DEPENDENCIES \"${${PORT}_DEPENDENCIES}\" CACHE INTERNAL \"\")\n")
endfunction()
