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
    cmake_parse_arguments(_csc "" "SOURCE_PATH" "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG" ${ARGN})
     
    # Find qmake executable
    set(_triplet_hostbindir ${CURRENT_INSTALLED_DIR}/tools/qt5/bin)
    find_program(QMAKE_COMMAND NAMES qmake PATHS ${VCPKG_QT_HOST_TOOLS_ROOT_DIR}/bin ${_triplet_hostbindir})

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
    
    
    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
    endif()
    
    foreach(buildtype ${VCPKG_BUILD_LIST})
        #Cleanup
        file(REMOVE_RECURSE "${VCPKG_BUILDTREE_TRIPLET_DIR_${buildtype}}")
        
        string(TOLOWER ${buildtype} _lowerbuildtype)
        set(_qt_conf "${VCPKG_BUILDTREE_TRIPLET_DIR_${buildtype}}/qt.conf")
        
        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_${_lowerbuildtype}.conf" "${_qt_conf}")
        
        message(STATUS "Configuring ${VCPKG_BUILD_TRIPLET_${buildtype}}")
        
        file(MAKE_DIRECTORY "${VCPKG_BUILDTREE_TRIPLET_DIR_${buildtype}}")
        vcpkg_execute_required_process(
            COMMAND ${QMAKE_COMMAND} ${VCPKG_BUILD_QMAKE_CONFIG_${_buildname}} ${_csc_OPTIONS} ${_csc_OPTIONS_${buildtype}} ${_csc_SOURCE_PATH} -qtconf "${_qt_conf}"
            WORKING_DIRECTORY "${VCPKG_BUILDTREE_TRIPLET_DIR_${buildtype}}"
            LOGNAME config-${VCPKG_BUILD_TRIPLET_${buildtype}}
        )
        
        message(STATUS "Configuring ${VCPKG_BUILD_TRIPLET_${buildtype}} done")
        
        unset(_lowerbuildtype)
        unset(_qt_conf)
    endforeach()


endfunction()