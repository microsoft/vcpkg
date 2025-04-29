include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_make.cmake")

function(vcpkg_make_configure)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "AUTORECONF;COPY_SOURCE;DISABLE_MSVC_WRAPPERS;DISABLE_CPPFLAGS;DISABLE_DEFAULT_OPTIONS;DISABLE_MSVC_TRANSFORMATIONS"
        "SOURCE_PATH"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;PRE_CONFIGURE_CMAKE_COMMANDS;LANGUAGES"
    )

    z_vcpkg_unparsed_args(FATAL_ERROR)

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

    set(src_dir "${arg_SOURCE_PATH}")

    z_vcpkg_warn_path_with_spaces()

    set(prepare_flags_opts "")
    if(arg_DISABLE_MSVC_WRAPPERS)
        list(APPEND prepare_flags_opts "DISABLE_MSVC_WRAPPERS")        
    endif()
    if(arg_DISABLE_CPPFLAGS)
        list(APPEND prepare_flags_opts "DISABLE_CPPFLAGS")
    endif()
    if(DEFINED arg_LANGUAGES)
        list(APPEND prepare_flags_opts "LANGUAGES" ${arg_LANGUAGES})
    endif()

    # Create cached cmake vars for this invocation's languages
    z_vcpkg_make_get_cmake_vars(LANGUAGES ${arg_LANGUAGES})

    set(escaping "")
    if(arg_DISABLE_MSVC_TRANSFORMATIONS)
      set(escaping NO_FLAG_ESCAPING)
    endif()

    z_vcpkg_set_global_property(make_prepare_flags_opts "${prepare_flags_opts}")
    z_vcpkg_make_prepare_flags(${prepare_flags_opts} ${escaping} C_COMPILER_NAME ccname FRONTEND_VARIANT_OUT frontend)

    if(DEFINED VCPKG_MAKE_BUILD_TRIPLET)
        set(BUILD_TRIPLET "${VCPKG_MAKE_BUILD_TRIPLET}")
    endif()
    if(NOT DEFINED BUILD_TRIPLET)
        z_vcpkg_make_get_configure_triplets(BUILD_TRIPLET COMPILER_NAME "${ccname}")
    endif()

    if(NOT arg_DISABLE_MSVC_WRAPPERS AND "${frontend}" STREQUAL "MSVC" )
        # Lets assume that wrappers are only required for MSVC like frontends.
        vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-make/wrappers")
    endif()

    vcpkg_make_get_shell(shell_var)
    set(shell_cmd "${shell_var}")

    if(arg_AUTORECONF)
      vcpkg_run_autoreconf("${shell_cmd}" "${src_dir}")
    endif()

    # Backup environment variables
    set(cm_FLAGS AR AS CC C CCAS CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJXX R RC UPC Y)

    list(TRANSFORM cm_FLAGS APPEND "FLAGS")
    vcpkg_backup_env_variables(VARS 
        ${cm_FLAGS}
    # General backup
        PATH
    # Used by gcc/linux
        C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH
    # Used by cl
        INCLUDE LIB LIBPATH _CL_ _LINK_
    )
    z_vcpkg_make_set_common_vars()

    foreach(config IN LISTS buildtypes)
        string(TOUPPER "${config}" configup)
        set(target_dir "${workdir_${configup}}")
        file(REMOVE_RECURSE "${target_dir}")
        file(MAKE_DIRECTORY "${target_dir}")
        file(RELATIVE_PATH relative_build_path "${target_dir}" "${src_dir}")
        if(arg_COPY_SOURCE)
            file(COPY "${src_dir}/" DESTINATION "${target_dir}")
            set(relative_build_path ".")
        endif()

        z_vcpkg_make_prepare_programs(configure_env ${prepare_flags_opts} CONFIG "${configup}" BUILD_TRIPLET "${BUILD_TRIPLET}")

        set(opts "")
        if(NOT arg_DISABLE_DEFAULT_OPTIONS)
          z_vcpkg_make_default_path_and_configure_options(opts AUTOMAKE CONFIG "${configup}")
        endif()

        set(configure_path_from_wd "./${relative_build_path}/configure")

        foreach(cmd IN LISTS arg_PRE_CONFIGURE_CMAKE_COMMANDS)
            cmake_language(CALL ${cmd} ${configup})
        endforeach()

        vcpkg_make_run_configure(SHELL
                                    "${shell_cmd}"
                                 CONFIG
                                    "${configup}"
                                 CONFIGURE_ENV
                                    "${configure_env}"
                                 CONFIGURE_PATH
                                    "${configure_path_from_wd}"
                                 OPTIONS 
                                    ${BUILD_TRIPLET}
                                    ${arg_OPTIONS}
                                    ${opts}
                                    ${arg_OPTIONS_${configup}}
                                 WORKING_DIRECTORY 
                                    "${target_dir}" 
                                 ${extra_configure_opts}
                                )
    endforeach()

    # Restore environment
    vcpkg_restore_env_variables(VARS 
        ${cm_FLAGS} 
        C_INCLUDE_PATH CPLUS_INCLUDE_PATH LIBRARY_PATH LD_LIBRARY_PATH
        INCLUDE LIB LIBPATH _CL_ _LINK_
    )

    find_program(Z_VCPKG_MAKE NAMES make gmake NAMES_PER_DIR REQUIRED)
endfunction()
