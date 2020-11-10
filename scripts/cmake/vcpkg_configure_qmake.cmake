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

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_config RELEASE)
        set(PKGCONFIG_INSTALLED_DIR "${_VCPKG_INSTALLED_PKGCONF}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
        set(PKGCONFIG_INSTALLED_SHARE_DIR "${_VCPKG_INSTALLED_PKGCONF}/share/pkgconfig")
        set(PKGCONFIG_PACKAGES_DIR "${_VCPKG_PACKAGES_PKGCONF}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
        set(PKGCONFIG_PACKAGES_SHARE_DIR "${_VCPKG_PACKAGES_PKGCONF}/share/pkgconfig")
        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_${_config} $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_SHARE_DIR}")
        endif()

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
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-rel.log")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-rel.log")
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(_config DEBUG)
        set(PATH_SUFFIX_DEBUG /debug)
        set(PKGCONFIG_INSTALLED_DIR "${_VCPKG_INSTALLED_PKGCONF}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
        set(PKGCONFIG_INSTALLED_SHARE_DIR "${_VCPKG_INSTALLED_PKGCONF}/share/pkgconfig")
        set(PKGCONFIG_PACKAGES_DIR "${_VCPKG_PACKAGES_PKGCONF}${PATH_SUFFIX_${_config}}/lib/pkgconfig")
        set(PKGCONFIG_PACKAGES_SHARE_DIR "${_VCPKG_PACKAGES_PKGCONF}/share/pkgconfig")
        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(BACKUP_ENV_PKG_CONFIG_PATH_${_config} $ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_INSTALLED_SHARE_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_DIR}${VCPKG_HOST_PATH_SEPARATOR}${PKGCONFIG_PACKAGES_SHARE_DIR}")
        endif()

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
        if(EXISTS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-dbg.log")
            file(RENAME "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-dbg.log")
        endif()
    endif()

endfunction()