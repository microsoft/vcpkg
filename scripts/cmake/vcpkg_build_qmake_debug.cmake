#.rst:
# .. command:: vcpkg_build_qmake_debug
#
#  Build a qmake-based project, previously configured using vcpkg_configure_qmake_debug. 
#
#  ::
#  vcpkg_build_qmake_debug()
#
#
# [1] : http://doc.qt.io/qt-5/qmake-variable-reference.html

function(vcpkg_build_qmake_debug)
    cmake_parse_arguments(_csc "" "" "TARGETS" ${ARGN})
    vcpkg_find_acquire_program(JOM)

    # Make sure that the linker finds the libraries used 
    set(ENV_PATH_BACKUP "$ENV{PATH}")
    set(ENV{PATH} "${CURRENT_INSTALLED_DIR}/debug/lib;${CURRENT_INSTALLED_DIR}/debug/bin;${CURRENT_INSTALLED_DIR}/debug/tools/qt5;$ENV{PATH}")
    
    message(STATUS "Package ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND ${JOM} ${_csc_TARGETS}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME package-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Package ${TARGET_TRIPLET}-dbg done")
    
    # Restore the original value of ENV{PATH}
    set(ENV{PATH} "${ENV_PATH_BACKUP}")
endfunction()
