include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg-make.cmake")

function(vcpkg_make_install)
# Replacement for vcpkg_(install|build)_make
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ADD_BIN_TO_PATH;DISABLE_PARALLEL;NO_DESTDIR"
        "LOGFILE_ROOT;SUBPATH;MAKEFILE;TARGETS"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE"
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)

    if(NOT DEFINED arg_LOGFILE_ROOT)
        set(arg_LOGFILE_ROOT "make")
    endif()

    if(NOT DEFINED arg_TARGETS)
        set(arg_TARGETS "all;install")
    endif()

    if (NOT DEFINED arg_MAKEFILE)
        set(arg_MAKEFILE Makefile)
    endif()

    # Can be set in the triplet to append options for configure
    if(DEFINED VCPKG_MAKE_OPTIONS)
        list(APPEND arg_OPTIONS ${VCPKG_MAKE_OPTIONS})
    endif()
    if(DEFINED VCPKG_MAKE_OPTIONS_RELEASE)
        list(APPEND arg_OPTIONS_RELEASE ${VCPKG_MAKE_OPTIONS_RELEASE})
    endif()
    if(DEFINED VCPKG_MAKE_OPTIONS_DEBUG)
        list(APPEND arg_OPTIONS_DEBUG ${VCPKG_MAKE_OPTIONS_DEBUG})
    endif()


    if(WIN32)
        set(Z_VCPKG_INSTALLED "${CURRENT_INSTALLED_DIR}")
    else()
        string(REPLACE " " "\ " Z_VCPKG_INSTALLED "${CURRENT_INSTALLED_DIR}")
    endif()

    if(NOT DEFINED Z_VCPKG_MAKE AND CMAKE_HOST_WIN32) # TODO: use a different approach here?
        vcpkg_make_setup_win_msys(msys_root)
    endif()
    find_program(Z_VCPKG_MAKE NAMES make gmake NAMES_PER_DIR REQUIRED)
    set(make_command "${Z_VCPKG_MAKE}")

    set(destdir "${CURRENT_PACKAGES_DIR}")
    if (CMAKE_HOST_WIN32)
        set(path_backup "$ENV{PATH}")
        vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-make/wrappers") # This probably doesn't hurt but should it be guarded?
        string(REPLACE " " [[\ ]] vcpkg_package_prefix "${CURRENT_PACKAGES_DIR}")
        string(REGEX REPLACE [[([a-zA-Z]):/]] [[/\1/]] destdir "${vcpkg_package_prefix}")
    endif()

    vcpkg_backup_env_variables(VARS LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH CPPFLAGS CFLAGS CXXFLAGS RCFLAGS)

    z_vcpkg_make_set_common_vars()
    z_vcpkg_get_global_property(prepare_flags_opts "make_prepare_flags_opts")
    vcpkg_make_prepare_flags(${prepare_flags_opts})

    set(prepare_env_opts "")
    if(arg_ADD_BIN_TO_PATH)
        set(prepare_env_opts ADD_BIN_TO_PATH)
    endif()

    foreach(buildtype IN LISTS buildtypes)
        string(TOUPPER "${buildtype}" cmake_buildtype)
        set(short_buildtype "${suffix_${cmake_buildtype}}")
        set(path_suffix "${path_suffix_${cmake_buildtype}}")

        set(working_directory "${workdir_${cmake_buildtype}}/${arg_SUBPATH}")
        message(STATUS "Building/Installing ${TARGET_TRIPLET}-${short_buildtype}")

        # Setup environment
        vcpkg_make_prepare_env("${cmake_buildtype}" ${prepare_env_opts})

        set(destdir_opt "")
        if(NOT arg_NO_DESTDIR)
            set(destdir_opt "DESTDIR=${destdir}")
        endif()

        foreach(target IN LISTS arg_TARGETS)
            vcpkg_list(SET make_cmd_line ${make_command} ${arg_OPTIONS} ${arg_OPTIONS_${cmake_buildtype}} V=1 -j ${VCPKG_CONCURRENCY} --trace -f ${arg_MAKEFILE} ${target} ${destdir_opt})
            vcpkg_list(SET no_parallel_make_cmd_line ${make_command} ${arg_OPTIONS} ${arg_OPTIONS_${cmake_buildtype}} V=1 -j 1 --trace -f ${arg_MAKEFILE} ${target} ${destdir_opt})
            message(STATUS "Making target '${target}' for ${TARGET_TRIPLET}-${short_buildtype}")
            if (arg_DISABLE_PARALLEL)
                vcpkg_execute_build_process(
                        COMMAND ${no_parallel_make_cmd_line}
                        WORKING_DIRECTORY "${working_directory}"
                        LOGNAME "${arg_LOGFILE_ROOT}-${target}-${TARGET_TRIPLET}-${short_buildtype}"
                )
            else()
                vcpkg_execute_build_process(
                        COMMAND ${make_cmd_line}
                        NO_PARALLEL_COMMAND ${no_parallel_make_cmd_line}
                        WORKING_DIRECTORY "${working_directory}"
                        LOGNAME "${arg_LOGFILE_ROOT}-${target}-${TARGET_TRIPLET}-${short_buildtype}"
                )
            endif()
            file(READ "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_ROOT}-${target}-${TARGET_TRIPLET}-${short_buildtype}-out.log" logdata) 
            if(logdata MATCHES "Warning: linker path does not have real file for library")
                message(FATAL_ERROR "libtool could not find a file being linked against!")
            endif()
        endforeach()

        vcpkg_make_restore_env()

        vcpkg_restore_env_variables(VARS LIB LIBPATH LIBRARY_PATH)
    endforeach()

    ## Cleanup
    string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" destdir_suffix "${CURRENT_INSTALLED_DIR}")
    if (EXISTS "${CURRENT_PACKAGES_DIR}${destdir_suffix}") # <- Means DESTDIR was correctly used; need to move files.
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}_tmp")
        file(RENAME "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}_tmp")
        file(RENAME "${CURRENT_PACKAGES_DIR}_tmp${destdir_suffix}" "${CURRENT_PACKAGES_DIR}")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}_tmp")
    endif()

    # Remove libtool files since they contain absolute paths and are not necessary. 
    file(GLOB_RECURSE libtool_files "${CURRENT_PACKAGES_DIR}/**/*.la")
    if(libtool_files)
        file(REMOVE ${libtool_files})
    endif()

    if (CMAKE_HOST_WIN32)
        set(ENV{PATH} "${path_backup}")
    endif()

    vcpkg_restore_env_variables(VARS LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH CPPFLAGS CFLAGS CXXFLAGS RCFLAGS)
endfunction()