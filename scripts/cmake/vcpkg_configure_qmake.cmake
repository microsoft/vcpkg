#.rst:
# .. command:: vcpkg_configure_qmake
#
#  Configure a qmake-based project. 
#  It is assume that the qmake project CONFIG variable is 
#  "debug_and_release" (the default value on Windows, see [1]).
#  Using this option, only one Makefile for building both Release and Debug 
#  libraries is generated, that then can be run using the vcpkg_install_qmake
#  command. 
#
#  ::
#  vcpkg_configure_qmake(SOURCE_PATH <pro_file_path>
#                        [OPTIONS arg1 [arg2 ...]]
#                        )
#
#  ``PROJECT_PATH``
#    The path to the *.pro qmake project file.
#  ``OPTIONS``
#    The options passed to qmake.
#
# [1] : http://doc.qt.io/qt-5/qmake-variable-reference.html

function(vcpkg_configure_qmake)
    cmake_parse_arguments(_csc "" "SOURCE_PATH" "OPTIONS" ${ARGN})
    
    # Find qmake exectuable 
    find_program(QMAKE_COMMAND NAMES qmake)
    
    if(NOT QMAKE_COMMAND)
        BUILD_ERROR("vcpkg_configure_qmake: impossible to find qmake.")
    endif()

    # Cleanup build directories 
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

    message(STATUS "Configuring ${TARGET_TRIPLET}")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
    vcpkg_execute_required_process(
        COMMAND ${QMAKE_COMMAND} ${_csc_SOURCE_PATH} ${_csc_OPTIONS}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}
        LOGNAME config-${TARGET_TRIPLET}
    )
    message(STATUS "Configuring ${TARGET_TRIPLET} done")
endfunction()