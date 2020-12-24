#[===[.md:
# vcpkg_build_qmake

Build a qmake-based project, previously configured using vcpkg_configure_qmake.

```cmake
vcpkg_build_qmake()
```
#]===]

function(vcpkg_build_qmake)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 _csc "SKIP_MAKEFILES" "BUILD_LOGNAME" "TARGETS;RELEASE_TARGETS;DEBUG_TARGETS")

    if(CMAKE_HOST_WIN32)
        if (VCPKG_QMAKE_USE_NMAKE)
            find_program(NMAKE nmake)
            set(INVOKE "${NMAKE}")
            get_filename_component(NMAKE_EXE_PATH ${NMAKE} DIRECTORY)
            set(PATH_GLOBAL "$ENV{PATH}")
            set(ENV{PATH} "$ENV{PATH};${NMAKE_EXE_PATH}")
            set(ENV{CL} "$ENV{CL} /MP${VCPKG_CONCURRENCY}")
        else()
            vcpkg_find_acquire_program(JOM)
            set(INVOKE "${JOM}")
        endif()
    else()
        find_program(MAKE make)
        set(INVOKE "${MAKE}")
    endif()

    # Make sure that the linker finds the libraries used
    set(ENV_PATH_BACKUP "$ENV{PATH}")

    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}" NATIVE_INSTALLED_DIR)

    if(NOT _csc_BUILD_LOGNAME)
        set(_csc_BUILD_LOGNAME build)
    endif()

    function(run_jom TARGETS LOG_PREFIX LOG_SUFFIX)
        message(STATUS "Package ${LOG_PREFIX}-${TARGET_TRIPLET}-${LOG_SUFFIX}")
        vcpkg_execute_build_process(
            COMMAND ${INVOKE} -j ${VCPKG_CONCURRENCY} ${TARGETS}
            NO_PARALLEL_COMMAND ${INVOKE} -j 1 ${TARGETS}
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${LOG_SUFFIX}
            LOGNAME package-${LOG_PREFIX}-${TARGET_TRIPLET}-${LOG_SUFFIX}
        )
    endfunction()

    # This fixes issues on machines with default codepages that are not ASCII compatible, such as some CJK encodings
    set(ENV_CL_BACKUP "$ENV{_CL_}")
    set(ENV{_CL_} "/utf-8")

    #Replace with VCPKG variables if PR #7733 is merged
    unset(BUILDTYPES)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(_buildname "DEBUG")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "dbg")
        set(_path_suffix_${_buildname} "/debug")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        set(_buildname "RELEASE")
        list(APPEND BUILDTYPES ${_buildname})
        set(_short_name_${_buildname} "rel")
        set(_path_suffix_${_buildname} "")
    endif()
    unset(_buildname)

    foreach(_buildname ${BUILDTYPES})
        set(_installed_prefix_ "${CURRENT_INSTALLED_DIR}${_path_suffix_${_buildname}}")
        set(_installed_libpath_ "${_installed_prefix_}/lib/${VCPKG_HOST_PATH_SEPARATOR}${_installed_prefix_}/lib/manual-link/")

        vcpkg_add_to_path(PREPEND "${_installed_prefix_}/bin")
        vcpkg_add_to_path(PREPEND "${_installed_prefix_}/lib")

        # We set LD_LIBRARY_PATH ENV variable to allow executing Qt tools (rcc,...) even with dynamic linking
        if(CMAKE_HOST_UNIX)
            if(DEFINED ENV{LD_LIBRARY_PATH})
                set(_ld_library_path_defined_ TRUE)
                set(_ld_library_path_backup_ $ENV{LD_LIBRARY_PATH})
                set(ENV{LD_LIBRARY_PATH} "${_installed_libpath_}${VCPKG_HOST_PATH_SEPARATOR}${_ld_library_path_backup_}")
            else()
                set(_ld_library_path_defined_ FALSE)
                set(ENV{LD_LIBRARY_PATH} "${_installed_libpath_}")
            endif()
        endif()
        
        list(APPEND _csc_${_buildname}_TARGETS ${_csc_TARGETS})
        if(NOT _csc_SKIP_MAKEFILES)
            run_jom(qmake_all makefiles ${_short_name_${_buildname}})
        endif()
        run_jom("${_csc_${_buildname}_TARGETS}" ${_csc_BUILD_LOGNAME} ${_short_name_${_buildname}})

        # Restore backup
        if(CMAKE_HOST_UNIX)
            if(_ld_library_path_defined_)
                set(ENV{LD_LIBRARY_PATH} "${_ld_library_path_backup_}")                
            else()
                unset(ENV{LD_LIBRARY_PATH})
            endif()
        endif()
    endforeach()

    # Restore the original value of ENV{PATH}
    set(ENV{PATH} "${ENV_PATH_BACKUP}")
    set(ENV{_CL_} "${ENV_CL_BACKUP}")
endfunction()
