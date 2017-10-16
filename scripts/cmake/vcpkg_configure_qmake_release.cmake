#.rst:
# .. command:: vcpkg_configure_qmake_release
#
#  Configure a qmake-based project. 
#  This sets the config variable to release and outputs to
#  a release triplet directory.
#
#  ::
#  vcpkg_configure_qmake_release(SOURCE_PATH <pro_file_path>
#                        [OPTIONS arg1 [arg2 ...]]
#                        )
#
#  ``SOURCE_PATH``
#    The path to the *.pro qmake project file.
#  ``OPTIONS``
#    The options passed to qmake.
#
# [1] : http://doc.qt.io/qt-5/qmake-variable-reference.html

function(vcpkg_configure_qmake_release)
    cmake_parse_arguments(_csc "" "SOURCE_PATH" "OPTIONS" ${ARGN})
    
    # Find qmake exectuable 
    find_program(QMAKE_COMMAND NAMES qmake.exe PATHS ${CURRENT_INSTALLED_DIR}/tools/qt5)
    
    if(NOT QMAKE_COMMAND)
        message(FATAL_ERROR "vcpkg_configure_qmake: unable to find qmake.")
    endif()

    # Cleanup build directories 
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)

    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    vcpkg_execute_required_process(
        COMMAND ${QMAKE_COMMAND} CONFIG-=debug CONFIG+=release ${_csc_OPTIONS} -d ${_csc_SOURCE_PATH}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME config-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
    unset(QMAKE_COMMAND)
    unset(QMAKE_COMMAND PARENT_SCOPE)
    unset(QMAKE_COMMAND CACHE)
endfunction()