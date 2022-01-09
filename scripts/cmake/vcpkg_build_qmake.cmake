#[===[.md:
# vcpkg_build_qmake

Build a qmake-based project, previously configured using vcpkg_configure_qmake.

```cmake
vcpkg_build_qmake()
```
#]===]

function(z_run_jom_build invoke_command targets log_prefix log_suffix)
    message(STATUS "Package ${log_prefix}-${TARGET_TRIPLET}-${log_suffix}")
    vcpkg_execute_build_process(
        COMMAND "${invoke_command}" -j ${VCPKG_CONCURRENCY} ${targets}
        NO_PARALLEL_COMMAND "${invoke_command}" -j 1 ${targets}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${log_suffix}"
        LOGNAME "package-${log_prefix}-${TARGET_TRIPLET}-${log_suffix}"
    )
endfunction()

function(vcpkg_build_qmake)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "SKIP_MAKEFILES"
        "BUILD_LOGNAME"
        "TARGETS;RELEASE_TARGETS;DEBUG_TARGETS"
    )

    # Make sure that the linker finds the libraries used
    vcpkg_backup_env_variables(VARS PATH LD_LIBRARY_PATH CL _CL_)

    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(ENV{_CL_} "/utf-8")

    if(CMAKE_HOST_WIN32)
        if (VCPKG_QMAKE_USE_NMAKE)
            find_program(NMAKE nmake)
            set(invoke_command "${NMAKE}")
            get_filename_component(nmake_exe_path "${NMAKE}" DIRECTORY)
            vcpkg_host_path_list(APPEND ENV{PATH} "${nmake_exe_path}")
            set(ENV{CL} "$ENV{CL} /MP${VCPKG_CONCURRENCY}")
        else()
            vcpkg_find_acquire_program(JOM)
            set(invoke_command "${JOM}")
        endif()
    else()
        find_program(MAKE make)
        set(invoke_command "${MAKE}")
    endif()

    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)

    if(NOT DEFINED arg_BUILD_LOGNAME)
        set(arg_BUILD_LOGNAME build)
    endif()

    set(short_name_debug "dbg")
    set(path_suffix_debug "/debug")
    set(targets_debug "${arg_DEBUG_TARGETS}")

    set(short_name_release "rel")
    set(path_suffix_release "")
    set(targets_release "${arg_RELEASE_TARGETS}")

    if(NOT DEFINED VCPKG_BUILD_TYPE)
        set(items debug release)
    else()
        set(items release)
    endif()
    foreach(build_type IN ITEMS ${items})
        set(current_installed_prefix "${CURRENT_INSTALLED_DIR}${path_suffix_${build_type}}")

        vcpkg_add_to_path(PREPEND "${current_installed_prefix}/lib" "${current_installed_prefix}/bin")

        # We set LD_LIBRARY_PATH ENV variable to allow executing Qt tools (rcc,...) even with dynamic linking
        if(CMAKE_HOST_UNIX)
            set(ENV{LD_LIBRARY_PATH} "")
            vcpkg_host_path_list(APPEND ENV{LD_LIBRARY_PATH} "${current_installed_prefix}/lib" "${current_installed_prefix}/lib/manual-link")
        endif()

        vcpkg_list(SET targets ${targets_${build_type}} ${arg_TARGETS})
        if(NOT arg_SKIP_MAKEFILES)
            z_run_jom_build("${invoke_command}" qmake_all makefiles "${short_name_${build_type}}")
        endif()
        z_run_jom_build("${invoke_command}" "${targets}" "${arg_BUILD_LOGNAME}" "${short_name_${build_type}}")

        vcpkg_restore_env_variables(VARS PATH LD_LIBRARY_PATH)
    endforeach()

    vcpkg_restore_env_variables(VARS CL _CL_)
endfunction()
