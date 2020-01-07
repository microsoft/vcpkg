function(qt_fix_cmake PACKAGE_DIR_TO_FIX PORT_TO_FIX)
    set(BACKUP_PATH "$ENV{PATH}")
    #Find Python and add it to the path
    vcpkg_find_acquire_program(PYTHON2)
    get_filename_component(PYTHON2_EXE_PATH ${PYTHON2} DIRECTORY)
    vcpkg_add_to_path("${PYTHON2_EXE_PATH}")

    #Fix the cmake files if they exist
    if(EXISTS ${PACKAGE_DIR_TO_FIX}/lib/cmake)
        vcpkg_execute_required_process(
            COMMAND ${PYTHON2} ${CURRENT_INSTALLED_DIR}/share/qt5/fixcmake.py ${PORT_TO_FIX}
            WORKING_DIRECTORY ${PACKAGE_DIR_TO_FIX}/lib/cmake
            LOGNAME fix-cmake
        )
    endif()
    if(EXISTS ${PACKAGE_DIR_TO_FIX}/share/cmake)
        vcpkg_execute_required_process(
            COMMAND ${PYTHON2} ${CURRENT_INSTALLED_DIR}/share/qt5/fixcmake.py ${PORT_TO_FIX}
            WORKING_DIRECTORY ${PACKAGE_DIR_TO_FIX}/share/cmake
            LOGNAME fix-cmake
        )
    endif()
    #Install cmake files
    if(EXISTS ${PACKAGE_DIR_TO_FIX}/lib/cmake)
        file(MAKE_DIRECTORY ${PACKAGE_DIR_TO_FIX}/share)
        file(RENAME ${PACKAGE_DIR_TO_FIX}/lib/cmake ${PACKAGE_DIR_TO_FIX}/share/cmake)
    endif()
    #Remove extra cmake files
    if(EXISTS ${PACKAGE_DIR_TO_FIX}/debug/lib/cmake)
        file(REMOVE_RECURSE ${PACKAGE_DIR_TO_FIX}/debug/lib/cmake)
    endif()
    set(ENV{PATH} "${BACKUP_PATH}")
endfunction()