#[===[.md:
# vcpkg_build_qmake

Build a qmake-based project, previously configured using vcpkg_configure_qmake.

```cmake
vcpkg_build_qmake()
```
#]===]

function(z_run_jom_build TARGETS LOG_PREFIX LOG_SUFFIX)
    message(STATUS "Package ${LOG_PREFIX}-${TARGET_TRIPLET}-${LOG_SUFFIX}")
    vcpkg_execute_build_process(
        COMMAND "${invoke_command}" -j ${VCPKG_CONCURRENCY} ${TARGETS}
        NO_PARALLEL_COMMAND "${invoke_command}" -j 1 ${TARGETS}
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${LOG_SUFFIX}"
        LOGNAME "package-${LOG_PREFIX}-${TARGET_TRIPLET}-${LOG_SUFFIX}"
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
    set(env_path_backup "$ENV{PATH}")

    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(env_cl_backup "$ENV{_CL_}")
    set(ENV{_CL_} "/utf-8")

    if(CMAKE_HOST_WIN32)
        if (VCPKG_QMAKE_USE_NMAKE)
            find_program(nmake_executable nmake)
            set(invoke_command "${nmake_executable}")
            get_filename_component(nmake_exe_path "${nmake_executable}" DIRECTORY)
            vcpkg_host_path_list(APPEND ENV{PATH} "${nmake_exe_path}")
            vcpkg_host_path_list(APPEND ENV{CL} "/MP${VCPKG_CONCURRENCY}")
        else()
            vcpkg_find_acquire_program(JOM)
            set(invoke_command "${JOM}")
        endif()
    else()
        find_program(make_executable make)
        set(invoke_command "${make_executable}")
    endif()

    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)

    if(NOT arg_BUILD_LOGNAME)
        set(arg_BUILD_LOGNAME build)
    endif()

    #Replace with VCPKG variables if PR #7733 is merged
    set(short_name_debug "dbg")
    set(path_suffix_debug "/debug")
    set(targets_debug "${arg_DEBUG_TARGETS}")
    
    set(short_name_release "rel")
    set(path_suffix_release "")
    set(targets_release "${arg_RELEASE_TARGETS}")

    foreach(build_type IN ITEMS debug release)
        set(current_installed_prefix "${CURRENT_INSTALLED_DIR}${path_suffix_${build_type}}")
        set(current_installed_libpath "${current_installed_prefix}/lib/${VCPKG_HOST_PATH_SEPARATOR}${current_installed_prefix}/lib/manual-link/")

        vcpkg_add_to_path(PREPEND "${current_installed_prefix}/lib" "${current_installed_prefix}/bin")

        # We set LD_LIBRARY_PATH ENV variable to allow executing Qt tools (rcc,...) even with dynamic linking
        if(CMAKE_HOST_UNIX)
            if(DEFINED ENV{LD_LIBRARY_PATH})
                set(ld_library_path_backup "$ENV{LD_LIBRARY_PATH}")
                unset(ENV{LD_LIBRARY_PATH})
                vcpkg_host_path_list(APPEND ENV{LD_LIBRARY_PATH} "${current_installed_libpath}" "${ld_library_path_backup}")
            else()
                unset(ld_library_path_backup)
                unset(ENV{LD_LIBRARY_PATH})
                vcpkg_host_path_list(APPEND ENV{LD_LIBRARY_PATH} "${current_installed_libpath}")
            endif()
        endif()
        
        vcpkg_list(SET targets ${targets_${build_type}} ${arg_TARGETS})
        if(NOT arg_SKIP_MAKEFILES)
            z_run_jom_build(qmake_all makefiles "${short_name_${build_type}}")
        endif()
        z_run_jom_build("${targets}" "${arg_BUILD_LOGNAME}" "${short_name_${build_type}}")

        # Restore backup
        if(CMAKE_HOST_UNIX)
            if(DEFINED ld_library_path_backup)
                set(ENV{LD_LIBRARY_PATH} "${ld_library_path_backup}")                
            else()
                unset(ENV{LD_LIBRARY_PATH})
            endif()
        endif()
    endforeach()

    # Restore the original value of ENV{PATH}
    set(ENV{PATH} "${env_path_backup}")
    set(ENV{_CL_} "${env_cl_backup}")
endfunction()
