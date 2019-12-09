#.rst:
# .. command:: vcpkg_configure_qmake
#
#  Configure a qmake-based project.
#
#  ::
#  vcpkg_configure_qmake(SOURCE_PATH <pro_file_path>
#                        [OPTIONS arg1 [arg2 ...]]
#                        [OPTIONS_RELEASE arg1 [arg2 ...]]
#                        [OPTIONS_DEBUG arg1 [arg2 ...]]
#                        )
#
#  ``SOURCE_PATH``
#    The path to the *.pro qmake project file.
#  ``OPTIONS[_RELEASE|_DEBUG]``
#    The options passed to qmake.

function(vcpkg_configure_qmake)
    cmake_parse_arguments(_csc "" "SOURCE_PATH" "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;BUILD_OPTIONS;BUILD_OPTIONS_RELEASE;BUILD_OPTIONS_DEBUG" ${ARGN})
     
    # Find qmake executable
    set(_triplet_hostbindir ${CURRENT_INSTALLED_DIR}/tools/qt5/bin)
    if(DEFINED VCPKG_QT_HOST_TOOLS_ROOT_DIR)
        find_program(QMAKE_COMMAND NAMES qmake PATHS ${VCPKG_QT_HOST_TOOLS_ROOT_DIR}/bin ${_triplet_hostbindir} NO_DEFAULT_PATH)
    else()
        find_program(QMAKE_COMMAND NAMES qmake PATHS ${_triplet_hostbindir} NO_DEFAULT_PATH)
    endif()

    if(NOT QMAKE_COMMAND)
        message(FATAL_ERROR "vcpkg_configure_qmake: unable to find qmake.")
    endif()

    if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
        list(APPEND _csc_OPTIONS "CONFIG-=shared")
        list(APPEND _csc_OPTIONS "CONFIG*=static")
    else()
        list(APPEND _csc_OPTIONS "CONFIG-=static")
        list(APPEND _csc_OPTIONS "CONFIG*=shared")
        list(APPEND _csc_OPTIONS_DEBUG "CONFIG*=separate_debug_info")
    endif()
    
    if(VCPKG_TARGET_IS_WINDOWS AND ${VCPKG_CRT_LINKAGE} STREQUAL "static")
        list(APPEND _csc_OPTIONS "CONFIG*=static-runtime")
    endif()
    
    # Cleanup build directories
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        configure_file(${CURRENT_INSTALLED_DIR}/tools/qt5/qt_release.conf ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/qt.conf)
    
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
        if(DEFINED _csc_BUILD_OPTIONS OR DEFINED _csc_BUILD_OPTIONS_RELEASE)
            set(BUILD_OPT -- ${_csc_BUILD_OPTIONS} ${_csc_BUILD_OPTIONS_RELEASE})
        endif()
        vcpkg_execute_required_process(
            COMMAND ${QMAKE_COMMAND} CONFIG-=debug CONFIG+=release 
                    ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE} ${_csc_SOURCE_PATH} 
                    -qtconf "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/qt.conf" 
                    ${BUILD_OPT}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
            LOGNAME config-${TARGET_TRIPLET}-rel
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        configure_file(${CURRENT_INSTALLED_DIR}/tools/qt5/qt_debug.conf ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qt.conf)

        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
        if(DEFINED _csc_BUILD_OPTIONS OR DEFINED _csc_BUILD_OPTIONS_DEBUG)
            set(BUILD_OPT -- ${_csc_BUILD_OPTIONS} ${_csc_BUILD_OPTIONS_DEBUG})
        endif()
        vcpkg_execute_required_process(
            COMMAND ${QMAKE_COMMAND} CONFIG-=release CONFIG+=debug 
                    ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG} ${_csc_SOURCE_PATH} 
                    -qtconf "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/qt.conf"
                    ${BUILD_OPT}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
            LOGNAME config-${TARGET_TRIPLET}-dbg
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
    endif()

endfunction()