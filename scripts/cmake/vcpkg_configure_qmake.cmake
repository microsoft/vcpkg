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
        vcpkg_list(APPEND arg_OPTIONS "CONFIG-=shared")
        vcpkg_list(APPEND arg_OPTIONS "CONFIG*=static")
    else()
        vcpkg_list(APPEND arg_OPTIONS "CONFIG-=static")
        vcpkg_list(APPEND arg_OPTIONS "CONFIG*=shared")
        vcpkg_list(APPEND arg_OPTIONS_DEBUG "CONFIG*=separate_debug_info")
    endif()
    
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
        vcpkg_list(APPEND arg_OPTIONS "CONFIG*=static-runtime")
    endif()

    if(DEFINED VCPKG_OSX_DEPLOYMENT_TARGET)
        set(ENV{QMAKE_MACOSX_DEPLOYMENT_TARGET} ${VCPKG_OSX_DEPLOYMENT_TARGET})
    endif()

    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
    get_filename_component(PKGCONFIG_PATH "${PKGCONFIG}" DIRECTORY)
    vcpkg_add_to_path("${PKGCONFIG_PATH}")

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(config_type RELEASE)
        set(triplet_name "${TARGET_TRIPLET}-rel")
        set(pkgconfig_installed_dir "${_VCPKG_INSTALLED_PKGCONF}${PATH_SUFFIX_${config_type}}/lib/pkgconfig")
        set(pkgconfig_installed_share_dir "${_VCPKG_INSTALLED_PKGCONF}/share/pkgconfig")
        set(pkgconfig_packages_dir "${_VCPKG_PACKAGES_PKGCONF}${PATH_SUFFIX_${config_type}}/lib/pkgconfig")
        set(pkgconfig_packages_share_dir "${_VCPKG_PACKAGES_PKGCONF}/share/pkgconfig")
        set(current_binary_dir "${CURRENT_BUILDTREES_DIR}/${triplet_name}")

        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${pkgconfig_installed_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_installed_share_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_packages_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_packages_share_dir}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${pkgconfig_installed_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_installed_share_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_packages_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_packages_share_dir}")
        endif()

        # Cleanup build directories
        file(REMOVE_RECURSE "${current_binary_dir}")

        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_release.conf" "${current_binary_dir}/qt.conf")
    
        message(STATUS "Configuring ${triplet_name}")
        file(MAKE_DIRECTORY "${current_binary_dir}")
        if(DEFINED arg_BUILD_OPTIONS OR DEFINED arg_BUILD_OPTIONS_RELEASE)
            set(build_opt -- ${arg_BUILD_OPTIONS} ${arg_BUILD_OPTIONS_RELEASE})
        endif()
        vcpkg_execute_required_process(
            COMMAND "${qmake_executable}" CONFIG-=debug CONFIG+=release
                    ${arg_OPTIONS} ${arg_OPTIONS_RELEASE} ${arg_SOURCE_PATH}
                    -qtconf "${current_binary_dir}/qt.conf"
                    ${build_opt}
            WORKING_DIRECTORY "${current_binary_dir}"
            LOGNAME "config-${triplet_name}"
        )
        message(STATUS "Configuring ${triplet_name} done")
        if(EXISTS "${current_binary_dir}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${triplet_name}.log")
            file(RENAME "${current_binary_dir}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${triplet_name}.log")
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(config_type DEBUG)
        set(triplet_name "${TARGET_TRIPLET}-dbg")
        set(pkgconfig_installed_dir "${_VCPKG_INSTALLED_PKGCONF}${PATH_SUFFIX_${config_type}}/lib/pkgconfig")
        set(pkgconfig_installed_share_dir "${_VCPKG_INSTALLED_PKGCONF}/share/pkgconfig")
        set(pkgconfig_packages_dir "${_VCPKG_PACKAGES_PKGCONF}${PATH_SUFFIX_${config_type}}/lib/pkgconfig")
        set(pkgconfig_packages_share_dir "${_VCPKG_PACKAGES_PKGCONF}/share/pkgconfig")
        set(current_binary_dir "${CURRENT_BUILDTREES_DIR}/${triplet_name}")

        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "${pkgconfig_installed_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_installed_share_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_packages_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_packages_share_dir}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "${pkgconfig_installed_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_installed_share_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_packages_dir}${VCPKG_HOST_PATH_SEPARATOR}${pkgconfig_packages_share_dir}")
        endif()

        # Cleanup build directories
        file(REMOVE_RECURSE "${current_binary_dir}")

        configure_file("${CURRENT_INSTALLED_DIR}/tools/qt5/qt_debug.conf" "${current_binary_dir}/qt.conf")

        message(STATUS "Configuring ${triplet_name}")
        file(MAKE_DIRECTORY "${current_binary_dir}")
        if(DEFINED arg_BUILD_OPTIONS OR DEFINED arg_BUILD_OPTIONS_DEBUG)
            set(build_opt -- ${arg_BUILD_OPTIONS} ${arg_BUILD_OPTIONS_DEBUG})
        endif()
        vcpkg_execute_required_process(
            COMMAND "${qmake_executable}" CONFIG-=release CONFIG+=debug
                    ${arg_OPTIONS} ${arg_OPTIONS_DEBUG} ${arg_SOURCE_PATH}
                    -qtconf "${current_binary_dir}/qt.conf"
                    ${build_opt}
            WORKING_DIRECTORY "${current_binary_dir}"
            LOGNAME "config-${triplet_name}"
        )
        message(STATUS "Configuring ${triplet_name} done")
        if(EXISTS "${current_binary_dir}/config.log")
            file(REMOVE "${CURRENT_BUILDTREES_DIR}/internal-config-${triplet_name}.log")
            file(RENAME "${current_binary_dir}/config.log" "${CURRENT_BUILDTREES_DIR}/internal-config-${triplet_name}.log")
        endif()
    endif()

endfunction()
