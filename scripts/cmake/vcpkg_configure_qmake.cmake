function(vcpkg_configure_qmake)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 arg
        ""
        "SOURCE_PATH"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;BUILD_OPTIONS;BUILD_OPTIONS_RELEASE;BUILD_OPTIONS_DEBUG"
    )

    # Find qmake executable
    find_program(qmake_executable NAMES qmake PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/qt5/bin" NO_DEFAULT_PATH)

    if(NOT qmake_executable)
        message(FATAL_ERROR "vcpkg_configure_qmake: unable to find qmake.")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_list(APPEND arg_OPTIONS "CONFIG-=shared" "CONFIG*=static")
    else()
        vcpkg_list(APPEND arg_OPTIONS "CONFIG-=static" "CONFIG*=shared")
        vcpkg_list(APPEND arg_OPTIONS_DEBUG "CONFIG*=separate_debug_info")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
        vcpkg_list(APPEND arg_OPTIONS "CONFIG*=static-runtime")
    endif()

    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        z_vcpkg_setup_pkgconfig_path(BASE_DIRS "${CURRENT_INSTALLED_DIR}" "${CURRENT_PACKAGES_DIR}")

        set(current_binary_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

        # Cleanup build directories
        file(REMOVE_RECURSE "${current_binary_dir}")

        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_release.conf" "${current_binary_dir}/qt.conf")
    
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
        file(MAKE_DIRECTORY "${current_binary_dir}")

        vcpkg_list(SET build_opt_param)
        if(DEFINED arg_BUILD_OPTIONS OR DEFINED arg_BUILD_OPTIONS_RELEASE)
            vcpkg_list(SET build_opt_param -- ${arg_BUILD_OPTIONS} ${arg_BUILD_OPTIONS_RELEASE})
        endif()

        vcpkg_execute_required_process(
            COMMAND "${qmake_executable}" CONFIG-=debug CONFIG+=release
                    ${arg_OPTIONS} ${arg_OPTIONS_RELEASE} ${arg_SOURCE_PATH}
                    -qtconf "${current_binary_dir}/qt.conf"
                    ${build_opt_param}
            WORKING_DIRECTORY "${current_binary_dir}"
            LOGNAME "config-${TARGET_TRIPLET}-rel"
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
        if(EXISTS "${current_binary_dir}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-rel.log")
            file(RENAME "${current_binary_dir}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-rel.log")
        endif()

        z_vcpkg_restore_pkgconfig_path()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        z_vcpkg_setup_pkgconfig_path(BASE_DIRS "${CURRENT_INSTALLED_DIR}/debug" "${CURRENT_PACKAGES_DIR}/debug")

        set(current_binary_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")

        # Cleanup build directories
        file(REMOVE_RECURSE "${current_binary_dir}")

        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_debug.conf" "${current_binary_dir}/qt.conf")

        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
        file(MAKE_DIRECTORY "${current_binary_dir}")

        vcpkg_list(SET build_opt_param)
        if(DEFINED arg_BUILD_OPTIONS OR DEFINED arg_BUILD_OPTIONS_DEBUG)
            vcpkg_list(SET build_opt_param -- ${arg_BUILD_OPTIONS} ${arg_BUILD_OPTIONS_DEBUG})
        endif()
        vcpkg_execute_required_process(
            COMMAND "${qmake_executable}" CONFIG-=release CONFIG+=debug
                    ${arg_OPTIONS} ${arg_OPTIONS_DEBUG} ${arg_SOURCE_PATH}
                    -qtconf "${current_binary_dir}/qt.conf"
                    ${build_opt_param}
            WORKING_DIRECTORY "${current_binary_dir}"
            LOGNAME "config-${TARGET_TRIPLET}-dbg"
        )
        message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")
        if(EXISTS "${current_binary_dir}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-dbg.log")
            file(RENAME "${current_binary_dir}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${TARGET_TRIPLET}-dbg.log")
        endif()
        
        z_vcpkg_restore_pkgconfig_path()
    endif()

endfunction()
