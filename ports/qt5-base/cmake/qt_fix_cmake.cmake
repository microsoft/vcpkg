function(qt_fix_cmake PACKAGE_DIR_TO_FIX PORT_TO_FIX)
    #Install cmake files
    if(EXISTS ${PACKAGE_DIR_TO_FIX}/lib/cmake)
        file(MAKE_DIRECTORY ${PACKAGE_DIR_TO_FIX}/share)
        file(RENAME ${PACKAGE_DIR_TO_FIX}/lib/cmake ${PACKAGE_DIR_TO_FIX}/share/cmake)
    endif()
    #Remove extra cmake files
    if(EXISTS ${PACKAGE_DIR_TO_FIX}/debug/lib/cmake)
        file(REMOVE_RECURSE ${PACKAGE_DIR_TO_FIX}/debug/lib/cmake)
    endif()
endfunction()