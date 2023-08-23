# Be aware of https://github.com/microsoft/vcpkg/pull/31228
include_guard(GLOBAL)
include("${CMAKE_CURRENT_SOURCE_DIR}/vcpkg-make-common.cmake")

function(vcpkg_run_autoreconf bash_cmd work_dir)
# TODO:
# - Run autoreconf
# - Deal with tools like autopoint etc.
# does it make sense to parse configure.ac ?
    find_program(AUTORECONF autoreconf) # find_file instead ? autoreconf is a perl script. 
    if(NOT AUTORECONF)
        message(FATAL_ERROR "${PORT} requires autoconf from the system package manager (example: \"sudo apt-get install autoconf\")")
    endif()
    message(STATUS "Generating configure for ${TARGET_TRIPLET}")
    vcpkg_run_bash(
        BASH "${bash_cmd}"
        COMMAND "autoreconf -vfi"
        WORKING_DIRECTORY "${work_dir}"
        LOGNAME "autoconf-${TARGET_TRIPLET}"
    )
    message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
endfunction()

function(vcpkg_run_bash)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "" 
        "WORKING_DIRECTORY;LOGNAME"
        "BASH;COMMAND"
    )
    if (CMAKE_HOST_WIN32)
        vcpkg_execute_required_process(
            COMMAND ${arg_BASH} -c "${arg_COMMAND}"
            WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
            LOGNAME "${arg_LOGNAME}"
        )
    else()
        vcpkg_execute_required_process(
            COMMAND ${arg_COMMAND}
            WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
            LOGNAME "${arg_LOGNAME}"
        )
    endif()
endfunction()

function(vcpkg_make_setup_win_msys msys_out)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "" 
        ""
        "PACKAGES"
    )
    list(APPEND msys_require_packages autoconf-wrapper automake-wrapper binutils libtool make which)
    vcpkg_insert_msys_into_path(msys PACKAGES ${msys_require_packages} ${arg_PACKAGES})
    set("${msys_out}" "${msys}" PARENT_SCOPE)
endfunction()

function(vcpkg_make_get_shell out_var)
    set(bash_options "")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_make_setup_win_msys("${arg_ADDITIONAL_MSYS_PACKAGES}")
        if(arg_USE_WRAPPERS AND NOT arg_NO_WRAPPERS)
            vcpkg_prepare_win_compile_wrappers(msys_root)
        endif()
        set(bash_options --noprofile --norc --debug)
        set(bash_cmd "${msys_root}/usr/bin/bash.exe" CACHE STRING "")
    endif()
    find_program(bash_cmd NAMES bash sh REQUIRED)
    set("${out_var}" "{bash_cmd}" ${bash_options} PARENT_SCOPE)
endfunction()

function(vcpkg_prepare_compile_flags)

endfunction()

function(vcpkg_prepare_win_compile_wrappers)
endfunction()

function(vcpkg_prepare_pkgconfig config)
    set(subdir "")
    if(config MATCHES "(DEBUG|debug)")
        set(subdir "/debug")
    endif()

    foreach(envvar IN ITEMS PKG_CONFIG PKG_CONFIG_PATH)
        if(DEFINED ENV{${envvar}})
            z_vcpkg_set_global_property("make-pkg-config-backup-${envvar}" "$ENV{${envvar}}")
        else()
            z_vcpkg_set_global_property("make-pkg-config-backup-${envvar}")
        endif()
    endforeach()

    vcpkg_find_acquire_program(PKGCONFIG)
    get_filename_component(pkgconfig_path "${PKGCONFIG}" DIRECTORY)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")

    vcpkg_host_path_list(PREPEND ENV{PKG_CONFIG_PATH} 
                            "${CURRENT_INSTALLED_DIR}/share/pkgconfig/"
                            "${CURRENT_INSTALLED_DIR}${subdir}/lib/pkgconfig/"
                            "${CURRENT_PACKAGES_DIR}/share/pkgconfig/"
                            "${CURRENT_PACKAGES_DIR}${subdir}/lib/pkgconfig/"
                        )
endfunction()

function(vcpkg_restore_pkgconfig)
    foreach(envvar IN ITEMS PKG_CONFIG PKG_CONFIG_PATH)
        z_vcpkg_get_global_property(has_backup "make-pkg-config-backup-${envvar}" SET)
        if(has_backup)
            z_vcpkg_get_global_property(backup "make-pkg-config-backup-${envvar}")
            set("ENV{${envvar}}" "${backup}")
            z_vcpkg_set_global_property("make-pkg-config-backup-${envvar}")
        else()
            unset("ENV{${envvar}}")
        endif()
    endforeach()
endfunction()

function(z_vcpkg_make_get_build_triplet out)
    # --build: the machine you are building on
    # --host: the machine you are building for
    # --target: the machine that CC will produce binaries for
    # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
    # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
    z_vcpkg_make_determine_target_arch(TARGET_ARCH)
    z_vcpkg_make_determine_host_arch(BUILD_ARCH)

    set(build_triplet "")
    if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_IS_WINDOWS)
        # This is required since we are running in a msys
        # shell which will be otherwise identified as ${BUILD_ARCH}-pc-msys
        set(build_triplet "--build=${BUILD_ARCH}-pc-mingw32") 
    endif()

    set(host_triplet "")
    if(VCPKG_CROSSCOMPILING)
        if(VCPKG_TARGET_IS_WINDOWS)
            if(NOT TARGET_ARCH MATCHES "${BUILD_ARCH}" OR NOT CMAKE_HOST_WIN32)
                set(host_triplet"--host=${TARGET_ARCH}-pc-mingw32")
            elseif(VCPKG_TARGET_IS_UWP)
                # Needs to be different from --build to enable cross builds.
                set(host_triplet"--host=${TARGET_ARCH}-unknown-mingw32")
            endif()
        elseif(VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_OSX AND NOT "${TARGET_ARCH}" STREQUAL "${BUILD_ARCH}")
            set(host_triplet "--host=${TARGET_ARCH}-apple-darwin")
        elseif(VCPKG_TARGET_IS_LINUX) 
            # TODO: Use a different approach here
            if(VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "([^\/]*)-gcc$" AND CMAKE_MATCH_1)
                set(host_triplet "--host=${CMAKE_MATCH_1}") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
        endif()
    endif()

    set(output "${build_triplet} ${host_triplet}")
    string(STRIP "${output}" output)
    set("${out}" "${output}" PARENT_SCOPE)
endfunction()

function(vcpkg_make_prepare_env config)
# TODO
# - Setup the environment variables for make giving <config>
endfunction()

function(vcpkg_make_restore_env)

endfunction()

function(vcpkg_make_default_configure_options config)
endfunction()

function(vcpkg_copy_source config)
endfunction()

function(vcpkg_make_run_configure config)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "COPY_SOURCE" 
        "BASH;SOURCE_PATH;CONFIGURE_SUBPATH"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG"
    )
    vcpkg_prepare_pkgconfig("${config}")
    vcpkg_make_prepare_env("${config}")
    vcpkg_run_bash() # TODO: Add options. 
    vcpkg_make_restore_env()
    vcpkg_restore_pkgconfig()
endfunction()

function(vcpkg_make_configure) #
# Replacement for vcpkg_configure_make
# z_vcpkg_is_autoconf
# z_vcpkg_is_automake
    # Old signature
    #cmake_parse_arguments(PARSE_ARGV 0 arg
    #"AUTOCONFIG;SKIP_CONFIGURE;COPY_SOURCE;DISABLE_VERBOSE_FLAGS;NO_ADDITIONAL_PATHS;ADD_BIN_TO_PATH;NO_DEBUG;USE_WRAPPERS;NO_WRAPPERS;DETERMINE_BUILD_TRIPLET"
    #"SOURCE_PATH;PROJECT_SUBPATH;PRERUN_SHELL;BUILD_TRIPLET"
    #"OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;CONFIGURE_ENVIRONMENT_VARIABLES;CONFIG_DEPENDENT_ENVIRONMENT;ADDITIONAL_MSYS_PACKAGES"
    #)


    cmake_parse_arguments(PARSE_ARGV 0 arg
        "AUTOCONFIG;COPY_SOURCE;;NO_WRAPPERS;NO_CPP;NO_CONFIGURE_TRIPLET"
        "SOURCE_PATH;CONFIGURE_SUBPATH;BUILD_TRIPLET"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;CONFIGURE_ENVIRONMENT_VARIABLES;CONFIG_DEPENDENT_ENVIRONMENT;ADDITIONAL_MSYS_PACKAGES;RUN_SCRIPTS"
    )

    z_vcpkg_unparsed_args(FATAL_ERROR)
    #z_vcpkg_conflicting_args(arg_USE_WRAPPERS arg_NO_WRAPPERS)
    z_vcpkg_conflicting_args(arg_BUILD_TRIPLET arg_NO_CONFIGURE_TRIPLET)

    if(DEFINED VCPKG_MAKE_BUILD_TRIPLET)
        set(arg_BUILD_TRIPLET "${VCPKG_MAKE_BUILD_TRIPLET}")
    endif()
    if(NOT DEFINED arg_BUILD_TRIPLET AND NOT arg_NO_CONFIGURE_TRIPLET)
        z_vcpkg_make_get_build_triplet(arg_BUILD_TRIPLET) # <- Needs to know the compiler
    endif()

    # Can be set in the triplet to append options for configure
    if(DEFINED VCPKG_MAKE_CONFIGURE_OPTIONS)
        list(APPEND arg_OPTIONS ${VCPKG_MAKE_CONFIGURE_OPTIONS})
    endif()
    if(DEFINED VCPKG_MAKE_CONFIGURE_OPTIONS_RELEASE)
        list(APPEND arg_OPTIONS_RELEASE ${VCPKG_MAKE_CONFIGURE_OPTIONS_RELEASE})
    endif()
    if(DEFINED VCPKG_MAKE_CONFIGURE_OPTIONS_DEBUG)
        list(APPEND arg_OPTIONS_DEBUG ${VCPKG_MAKE_CONFIGURE_OPTIONS_DEBUG})
    endif()

    set(src_dir "${arg_SOURCE_PATH}/${arg_CONFIGURE_SUBPATH}")

    z_vcpkg_warn_path_with_spaces()

    if(arg_USE_WRAPPERS AND VCPKG_DETECTED_CMAKE_C_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        # Lets assume that wrappers are only required for MSVC like frontends.
        vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-make/wrappers")
    endif()

    vcpkg_make_get_shell(shell_cmd)

    if(arg_AUTOCONFIG)
        vcpkg_run_autoreconf("${shell_cmd}" "${src_dir}")
    endif()

    if(arg_RUN_SCRIPTS)
        message(STATUS "Running scripts for ${TARGET_TRIPLET} ${arg_RUN_SCRIPT}")
        set(run_index 0)
        foreach(script IN LISTS arg_RUN_SCRIPTS)
            message(STATUS "Running script:'${script}'")
            vcpkg_run_bash(
                BASH "${shell_cmd}"
                COMMAND "${script}"
                WORKING_DIRECTORY "${src_dir}"
                LOGNAME "run-script-${run_index}-${TARGET_TRIPLET}"
            )
            math(EXPR run_index "${run_index}+1")
        endforeach()
        message(STATUS "Finished running scripts for ${TARGET_TRIPLET}")
    endif()

    # Backup environment variables
    # CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJCXX R UPC Y 
    set(cm_FLAGS AR AS CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJXX R UPC Y RC)
    list(TRANSFORM cm_FLAGS APPEND "FLAGS")
    vcpkg_backup_env_variables(VARS 
        ${cm_FLAGS}
    # Used by gcc/linux
        C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH
    # Used by cl
        INCLUDE LIB LIBPATH _CL_ _LINK_
    )
    z_vcpkg_make_set_common_vars()
    z_vcpkg_make_prepare_flags()
    z_vcpkg_make_prepare_environment_common()

    set(build_configs RELEASE)
    if(NOT VCPKG_BUILD_TYPE)
        list(PREPEND build_configs DEBUG)
    endif()

    foreach(config IN LISTS build_configs)
        set(target_dir "${work_dir_${config_up}}")
        file(REMOVE_RECURSE "${target_dir}")
        file(MAKE_DIRECTORY "${target_dir}")
        file(RELATIVE_PATH relative_build_path "${target_dir}" "${src_dir}")
        if(arg_COPY_SOURCE)
            file(COPY "${src_dir}/" DESTINATION "${target_dir}")
            set(relative_build_path ".")
        endif()
        vcpkg_make_run_configure("${config}")
    endforeach()

    # Restore environment
    vcpkg_restore_env_variables(VARS 
        ${cm_FLAGS} 
        C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH
        INCLUDE LIB LIBPATH _CL_ _LINK_
    )

endfunction()

function(vcpkg_make_install)
# Replacement for vcpkg_(install|build)_make
# Needs to know if vcpkg_make_configure is a autoconf project

    # old signature
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ADD_BIN_TO_PATH;ENABLE_INSTALL;DISABLE_PARALLEL"
        "LOGFILE_ROOT;BUILD_TARGET;SUBPATH;MAKEFILE;INSTALL_TARGET"
        "OPTIONS"
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)

endfunction()

# Make config dependent injections possible via cmake_language(CALL)
# z_vcpkg_make_prepare_<CONFIG>_commands
# z_vcpkg_make_restore_commands