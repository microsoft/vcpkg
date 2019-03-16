#.rst:
# .. command:: vcpkg_configure_qmake
#
#  Configure a qmake-based project.
#
#  ::
#  vcpkg_configure_qmake(SOURCE_PATH <pro_file_path>
#                        [OPTIONS arg1 [arg2 ...]]
#                        )
#
#  ``SOURCE_PATH``
#    The path to the *.pro qmake project file.
#  ``OPTIONS``
#    The options passed to qmake.

function(vcpkg_configure_qmake)
    cmake_parse_arguments(_csc "" "SOURCE_PATH" "OPTIONS" ${ARGN})

    # Find qmake executable
    find_program(QMAKE_COMMAND NAMES qmake PATHS ${CURRENT_INSTALLED_DIR}/tools/qt5)

    if(NOT QMAKE_COMMAND)
        message(FATAL_ERROR "vcpkg_configure_qmake: unable to find qmake.")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND _csc_OPTIONS CONFIG+=staticlib)
    endif()

    # Cleanup build directories
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    configure_file(${CURRENT_INSTALLED_DIR}/tools/qt5/qt_release.conf ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/qt.conf)

    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    vcpkg_execute_required_process(
        COMMAND ${QMAKE_COMMAND} CONFIG-=debug CONFIG+=release ${_csc_OPTIONS} ${_csc_SOURCE_PATH} -qtconf "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/qt.conf"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME config-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")

    configure_file(${CURRENT_INSTALLED_DIR}/tools/qt5/qt_debug.conf ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qt.conf)

    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    vcpkg_execute_required_process(
        COMMAND ${QMAKE_COMMAND} CONFIG-=release CONFIG+=debug ${_csc_OPTIONS} ${_csc_SOURCE_PATH} -qtconf "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qt.conf"
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME config-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")

endfunction()