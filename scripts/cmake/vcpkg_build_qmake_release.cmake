#.rst:
# .. command:: vcpkg_build_qmake_release
#
#  Build a qmake-based project, previously configured using vcpkg_configure_qmake_release. 
#
#  ::
#  vcpkg_build_qmake_release()
#
#
# [1] : http://doc.qt.io/qt-5/qmake-variable-reference.html

function(vcpkg_build_qmake_release)
    vcpkg_find_acquire_program(JOM)

    # Make sure that the linker finds the libraries used 
    set(ENV_PATH_BACKUP "$ENV{PATH}")
    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/lib;${CURRENT_INSTALLED_DIR}/bin;${CURRENT_INSTALLED_DIR}/tools/qt5;$ENV{PATH}")
    
    message(STATUS "Package ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND ${JOM}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME package-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Package ${TARGET_TRIPLET}-rel done")
    
    # Restore the original value of ENV{PATH}
    set(ENV{PATH} "${ENV_PATH_BACKUP}")
endfunction()
