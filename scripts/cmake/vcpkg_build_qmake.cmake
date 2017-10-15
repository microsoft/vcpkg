#.rst:
# .. command:: vcpkg_build_qmake
#
#  Build a qmake-based project, previously configured using vcpkg_configure_qmake . 
#  As the CONFIG qmake option is assumed to be "debug_and_release" (the default value on Windows, see [1]),
#  both the debug and release libraries are build in the same build tree. 
#
#  ::
#  vcpkg_build_qmake()
#
#
# [1] : http://doc.qt.io/qt-5/qmake-variable-reference.html

function(vcpkg_build_qmake)
    vcpkg_find_acquire_program(JOM)

    # Make sure that the linker finds the libraries used 
    set(ENV_PATH_BACKUP ENV{PATH})
    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/lib;${CURRENT_INSTALLED_DIR}/debug/lib;${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/debug/bin;${CURRENT_INSTALLED_DIR}/tools/qt5;$ENV{PATH}")
    
    message(STATUS "Package ${TARGET_TRIPLET}")
    vcpkg_execute_required_process(
        COMMAND ${JOM}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}
        LOGNAME package-${TARGET_TRIPLET}
    )
    message(STATUS "Package ${TARGET_TRIPLET} done")
    
    # Restore the original value of ENV{PATH}
    set(ENV{PATH} ENV_PATH_BACKUP)
endfunction()
