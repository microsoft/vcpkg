#[===[.md:
# vcpkg_build_qmake

Build a qmake-based project, previously configured using vcpkg_configure_qmake.

```cmake
vcpkg_build_qmake()
```
#]===]

function(run_jom TARGETS LOG_PREFIX LOG_SUFFIX)
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

    if(CMAKE_HOST_WIN32)
        if (VCPKG_QMAKE_USE_NMAKE)
            find_program(nmake_executable nmake)
            set(invoke_command "${nmake_executable}")
            get_filename_component(NMAKE_EXE_PATH "${nmake_executable}" DIRECTORY)
            set(ENV{PATH} "$ENV{PATH};${NMAKE_EXE_PATH}")
            set(ENV{CL} "$ENV{CL} /MP${VCPKG_CONCURRENCY}")
        else()
            vcpkg_find_acquire_program(JOM)
            set(invoke_command "${JOM}")
        endif()
    else()
        find_program(make_executable make)
        set(invoke_command "${make_executable}")
    endif()

    # Make sure that the linker finds the libraries used
    set(env_path_backup "$ENV{PATH}")

    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)

    if(NOT arg_BUILD_LOGNAME)
        set(arg_BUILD_LOGNAME build)
    endif()

    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(env_cl_backup "$ENV{_CL_}")
    set(ENV{_CL_} "/utf-8")

    #Replace with VCPKG variables if PR #7733 is merged
    vcpkg_list(SET buildtypes)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(build_type_name "DEBUG")
        vcpkg_list(APPEND buildtypes "${build_type_name}")
        set(short_name_${build_type_name} "dbg")
        set(path_suffix_${build_type_name} "/debug")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(build_type_name "RELEASE")
        vcpkg_list(APPEND buildtypes "${build_type_name}")
        set(short_name_${build_type_name} "rel")
        set(path_suffix_${build_type_name} "")
    endif()

    foreach(build_type IN LISTS buildtypes)
        set(current_installed_prefix "${CURRENT_INSTALLED_DIR}${path_suffix_${build_type}}")
        set(current_installed_libpath "${current_installed_prefix}/lib/${VCPKG_HOST_PATH_SEPARATOR}${current_installed_prefix}/lib/manual-link/")

        vcpkg_add_to_path(PREPEND "${current_installed_prefix}/bin")
        vcpkg_add_to_path(PREPEND "${current_installed_prefix}/lib")

        # We set LD_LIBRARY_PATH ENV variable to allow executing Qt tools (rcc,...) even with dynamic linking
        if(CMAKE_HOST_UNIX)
            if(DEFINED ENV{LD_LIBRARY_PATH})
                set(is_ld_library_path_defined TRUE)
                set(ld_library_path_backup $ENV{LD_LIBRARY_PATH})
                set(ENV{LD_LIBRARY_PATH} "${current_installed_libpath}${VCPKG_HOST_PATH_SEPARATOR}${ld_library_path_backup}")
            else()
                set(is_ld_library_path_defined FALSE)
                set(ENV{LD_LIBRARY_PATH} "${current_installed_libpath}")
            endif()
        endif()
        
        vcpkg_list(APPEND arg_${build_type}_TARGETS ${arg_TARGETS})
        if(NOT arg_SKIP_MAKEFILES)
            run_jom(qmake_all makefiles ${short_name_${build_type}})
        endif()
        run_jom("${arg_${build_type}_TARGETS}" ${arg_BUILD_LOGNAME} ${short_name_${build_type}})

        # Restore backup
        if(CMAKE_HOST_UNIX)
            if(is_ld_library_path_defined)
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
