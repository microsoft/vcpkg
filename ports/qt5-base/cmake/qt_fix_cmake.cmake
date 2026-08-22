function(qt_fix_cmake PACKAGE_DIR_TO_FIX PORT_TO_FIX)

    file(GLOB_RECURSE cmakefiles ${PACKAGE_DIR_TO_FIX}/share/cmake/*.cmake ${PACKAGE_DIR_TO_FIX}/lib/cmake/*.cmake)
    foreach(cmakefile ${cmakefiles})
        file(READ "${cmakefile}" _contents)
        if(_contents MATCHES "_install_prefix}/tools/qt5/bin/([a-z0-9]+)") # there are only about 3 to 5 cmake files which require the fix in ports: qt5-tools qt5-xmlpattern at5-activeqt qt5-quick
            string(REGEX REPLACE "_install_prefix}/tools/qt5/bin/([a-z0-9]+)" "_install_prefix}/tools/${PORT_TO_FIX}/bin/\\1" _contents "${_contents}")
            file(WRITE "${cmakefile}" "${_contents}")
        endif()
    endforeach()
    
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