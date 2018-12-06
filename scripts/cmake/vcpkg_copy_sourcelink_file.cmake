## # vcpkg_copy_sourcelink_file
##
## Automatically copy Source Link file.
function(vcpkg_copy_sourcelink_file)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND EXISTS ${CURRENT_SOURCELINK_FILE})
        file(INSTALL ${CURRENT_SOURCELINK_FILE} DESTINATION ${CURRENT_PACKAGES_DIR}/sourcelink)
    endif()
endfunction()
