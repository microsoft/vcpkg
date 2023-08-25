include_guard(GLOBAL)
include("${CMAKE_CURRENT_SOURCE_DIR}/vcpkg-make.cmake")

function(vcpkg_make_install)
# Replacement for vcpkg_(install|build)_make
# Needs to know if vcpkg_make_configure is a autoconf project

    # old signature
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ADD_BIN_TO_PATH;DISABLE_PARALLEL" # NO_DESTDIR ?
        "LOGFILE_ROOT;SUBPATH;MAKEFILE;TARGETS"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE"
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)

    if(NOT DEFINED arg_LOGFILE_ROOT)
        set(arg_LOGFILE_ROOT "install")
    endif()

    if(NOT DEFINED arg_TARGETS)
        # IF AUTOCONFIG -> use install target instead?
        # IF AUTOCONFIG -> default to use destdir!
        set(arg_TARGETS "all")   
    endif()

    if (NOT DEFINED arg_MAKEFILE)
        set(arg_MAKEFILE Makefile)
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
        vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-make/wrappers")
        string(REPLACE " " [[\ ]] vcpkg_package_prefix "${CURRENT_PACKAGES_DIR}")
        string(REGEX REPLACE [[([a-zA-Z]):/]] [[/\1/]] destdir "${vcpkg_package_prefix}")
    endif()

    vcpkg_backup_env_variables(VARS LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH CPPFLAGS CFLAGS CXXFLAGS RCFLAGS)

    z_vcpkg_make_set_common_vars()

    foreach(buildtype IN LISTS buildtypes)
        string(TOUPPER "${buildtype}" cmake_buildtype)
        set(short_buildtype "${suffix_${cmake_buildtype}}")
        set(path_suffix "${path_suffix_${cmake_buildtype}}")

        set(working_directory "${workdir_${cmake_buildtype}}/${arg_SUBPATH}")
        message(STATUS "Building/Installing ${TARGET_TRIPLET}-${short_buildtype}")

        z_vcpkg_make_prepare_compile_flags(
            CONFIG "${cmake_buildtype}" 
            COMPILER_FRONTEND "${VCPKG_DETECTED_CMAKE_C_COMPILER_FRONTEND_VARIANT}" # TODO figure out how to get this in here. 
            ${flags_opts} # LANGUAGES/NO_CPP/NO_WRAPPERS <- Get hints about those via vcpkg_configure_make
        )

        # Setup environment
        set(ENV{CPPFLAGS} "${CPPFLAGS_${cmake_buildtype}}")
        set(ENV{CFLAGS} "${CFLAGS_${cmake_buildtype}}")
        set(ENV{CXXFLAGS} "${CXXFLAGS_${cmake_buildtype}}")
        set(ENV{RCFLAGS} "${RCFLAGS_${cmake_buildtype}}")
        set(ENV{LDFLAGS} "${LDFLAGS_${cmake_buildtype}}")
        vcpkg_list(APPEND lib_env_vars LIB LIBPATH LIBRARY_PATH) # LD_LIBRARY_PATH)
        foreach(lib_env_var IN LISTS lib_env_vars)
            if(EXISTS "${Z_VCPKG_INSTALLED}${path_suffix}/lib")
                vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${Z_VCPKG_INSTALLED}${path_suffix}/lib")
            endif()
            if(EXISTS "${Z_VCPKG_INSTALLED}${path_suffix}/lib/manual-link")
                vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${Z_VCPKG_INSTALLED}${path_suffix}/lib/manual-link")
            endif()
        endforeach()
        unset(lib_env_vars)

        # VCPKG_ABI_FLAGS isn't standard, but can be useful to reinject these flags into other variables
        #set(ENV{VCPKG_ABI_FLAGS} "${ABIFLAGS_${current_buildtype}}")

        if(LINK_ENV_${cmake_buildtype})
            set(config_link_backup "$ENV{_LINK_}")
            set(ENV{_LINK_} "${LINK_ENV_${cmake_buildtype}}")
        else()
            unset(config_link_backup)
        endif()

        set(env_backup_path "")
        if(arg_ADD_BIN_TO_PATH AND NOT VCPKG_CROSSCOMPILING)
            set(env_backup_path "$ENV{PATH}")
            vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}${path_suffix}/bin")
        endif()

        foreach(target IN LISTS arg_TARGETS)
            # TODO NO_DESTDIR
            vcpkg_list(SET make_cmd_line ${make_command} ${arg_OPTIONS} ${arg_OPTIONS_${cmake_buildtype}} V=1 -j ${VCPKG_CONCURRENCY} --trace -f ${arg_MAKEFILE} ${target} DESTDIR=${destdir})
            vcpkg_list(SET no_parallel_make_cmd_line ${make_command} ${arg_OPTIONS} ${arg_OPTIONS_${cmake_buildtype}} V=1 -j 1 --trace -f ${arg_MAKEFILE} ${target} DESTDIR=${destdir})
            message(STATUS "Making target '${target}' for ${TARGET_TRIPLET}-${short_buildtype}")
            if (arg_DISABLE_PARALLEL)
                vcpkg_execute_build_process(
                        COMMAND ${no_parallel_make_cmd_line}
                        WORKING_DIRECTORY "${working_directory}"
                        LOGNAME "${arg_LOGFILE_ROOT}-${TARGET_TRIPLET}-${short_buildtype}"
                )
            else()
                vcpkg_execute_build_process(
                        COMMAND ${make_cmd_line}
                        NO_PARALLEL_COMMAND ${no_parallel_make_cmd_line}
                        WORKING_DIRECTORY "${working_directory}"
                        LOGNAME "${arg_LOGFILE_ROOT}-${TARGET_TRIPLET}-${short_buildtype}"
                )
            endif()
        endforeach()

        file(READ "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_ROOT}-${TARGET_TRIPLET}-${short_buildtype}-out.log" logdata) 
        if(logdata MATCHES "Warning: linker path does not have real file for library")
            message(FATAL_ERROR "libtool could not find a file being linked against!")
        endif()

        if(DEFINED config_link_backup)
            set(ENV{_LINK_} "${config_link_backup}")
        endif()

        if(DEFINED env_backup_path)
            set(ENV{PATH} "${env_backup_path}")
        endif()

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