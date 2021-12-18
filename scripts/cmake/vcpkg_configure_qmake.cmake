#[===[.md:
# vcpkg_configure_qmake

Configure a qmake-based project.

```cmake
vcpkg_configure_qmake(
    SOURCE_PATH <pro_file_path>
    [OPTIONS arg1 [arg2 ...]]
    [OPTIONS_RELEASE arg1 [arg2 ...]]
    [OPTIONS_DEBUG arg1 [arg2 ...]]
    [BUILD_OPTIONS arg1 [arg2 ...]]
    [BUILD_OPTIONS_RELEASE arg1 [arg2 ...]]
    [BUILD_OPTIONS_DEBUG arg1 [arg2 ...]]
)
```

### SOURCE_PATH
The path to the *.pro qmake project file.

### OPTIONS, OPTIONS\_RELEASE, OPTIONS\_DEBUG
The options passed to qmake to the configure step.

### BUILD\_OPTIONS, BUILD\_OPTIONS\_RELEASE, BUILD\_OPTIONS\_DEBUG
The options passed to qmake to the build step.
#]===]

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

    vcpkg_backup_env_variables(VARS PKG_CONFIG_PATH)

    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
    get_filename_component(PKGCONFIG_PATH "${PKGCONFIG}" DIRECTORY)
    vcpkg_add_to_path("${PKGCONFIG_PATH}")

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH}
            "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
            "${CURRENT_INSTALLED_DIR}/share/pkgconfig"
            "${CURRENT_PACKAGES_DIR}/lib/pkgconfig"
            "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

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

        vcpkg_restore_env_variables(VARS PKG_CONFIG_PATH)
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH}
            "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
            "${CURRENT_INSTALLED_DIR}/share/pkgconfig"
            "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
            "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

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
    endif()

endfunction()
