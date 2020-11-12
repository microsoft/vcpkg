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
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _csc "" "SOURCE_PATH" "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;BUILD_OPTIONS;BUILD_OPTIONS_RELEASE;BUILD_OPTIONS_DEBUG")

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

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        list(APPEND _csc_OPTIONS "CONFIG-=shared")
        list(APPEND _csc_OPTIONS "CONFIG*=static")
    else()
        list(APPEND _csc_OPTIONS "CONFIG-=static")
        list(APPEND _csc_OPTIONS "CONFIG*=shared")
        list(APPEND _csc_OPTIONS_DEBUG "CONFIG*=separate_debug_info")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
        list(APPEND _csc_OPTIONS "CONFIG*=static-runtime")
    endif()

    # Cleanup build directories
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
    endif()

    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
    get_filename_component(PKGCONFIG_PATH "${PKGCONFIG}" DIRECTORY)
    vcpkg_add_to_path("${PKGCONFIG_PATH}")
    set(PKGCONFIG_INSTALLED_SHARE_DIR "${CURRENT_INSTALLED_DIR}/share/pkgconfig")
    set(PKGCONFIG_PACKAGES_SHARE_DIR "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

    foreach(buildtype IN LISTS VCPKG_BUILD_LIST)
        #Cleanup
        file(REMOVE_RECURSE "${VCPKG_BUILDTREE_TRIPLET_DIR_${buildtype}}")
        #Pkgconfig
        set(PKGCONFIG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}${VCPKG_PATH_SUFFIX_${buildtype}}/lib/pkgconfig")
        set(PKGCONFIG_PACKAGES_DIR "${CURRENT_PACKAGES_DIR}${VCPKG_PATH_SUFFIX_${buildtype}}/lib/pkgconfig")
        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_${buildtype} $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_SHARE_DIR}")
        endif()
        # qt.conf
        string(TOLOWER ${buildtype} _lowerbuildtype)
        set(_qt_conf "${VCPKG_BUILDTREE_TRIPLET_DIR_${buildtype}}/qt.conf")
        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_${_lowerbuildtype}.conf" "${_qt_conf}")

        message(STATUS "Configuring ${VCPKG_BUILD_TRIPLET_${buildtype}}")
        if(DEFINED _csc_BUILD_OPTIONS OR DEFINED _csc_BUILD_OPTIONS_${buildtype})
            set(BUILD_OPT -- ${_csc_BUILD_OPTIONS} ${_csc_BUILD_OPTIONS_${buildtype}})
        endif()
        file(MAKE_DIRECTORY "${VCPKG_BUILDTREE_TRIPLET_DIR_${buildtype}}")
        list(APPEND _csc_OPTIONS ${VCPKG_BUILD_QMAKE_CONFIG_${_buildname}})
        vcpkg_execute_required_process(
            COMMAND ${QMAKE_COMMAND}
                    ${_csc_OPTIONS} ${_csc_OPTIONS_${buildtype}} ${_csc_SOURCE_PATH}
                    -qtconf "${VCPKG_BUILDTREE_TRIPLET_DIR_${buildtype}}/qt.conf"
                    ${BUILD_OPT}
            WORKING_DIRECTORY "${VCPKG_BUILDTREE_TRIPLET_DIR_${buildtype}}"
            LOGNAME config-${VCPKG_BUILD_TRIPLET_${buildtype}})

        message(STATUS "Configuring ${VCPKG_BUILD_TRIPLET_${buildtype}} done")
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${VCPKG_BUILD_TRIPLET_${buildtype}}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${VCPKG_BUILD_TRIPLET_${buildtype}}.log")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/${VCPKG_BUILD_TRIPLET_${buildtype}}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${VCPKG_BUILD_TRIPLET_${buildtype}}.log")
        endif()
        if(DEFINED BACKUP_ENV_PKG_CONFIG_PATH_${buildtype})
            set(ENV{PKG_CONFIG_PATH} "${BACKUP_ENV_PKG_CONFIG_PATH_${buildtype}}")
        else()
            unset(ENV{PKG_CONFIG_PATH})
        endif()
        unset(_lowerbuildtype)
        unset(_qt_conf)
    endforeach()
endfunction()