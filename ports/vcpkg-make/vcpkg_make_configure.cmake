include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_make.cmake")

function(vcpkg_make_configure) # Replacement for vcpkg_configure_make
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "AUTOCONFIG;COPY_SOURCE;DISABLE_MSVC_WRAPPERS;DISABLE_CPPFLAGS;DISABLE_DEFAULT_OPTIONS;DISABLE_MSVC_FLAG_ESCAPING"
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
    else()
        
    endif()
    if(arg_DISABLE_CPPFLAGS)
        list(APPEND prepare_flags_opts "DISABLE_CPPFLAGS")
    endif()
    if(DEFINED arg_LANGUAGES)
        list(APPEND prepare_flags_opts "LANGUAGES" "${arg_LANGUAGES}")
    endif()

    set(escaping "")
    if(arg_DISABLE_MSVC_FLAG_ESCAPING)
      set(escaping NO_FLAG_ESCAPING)
    endif()

    z_vcpkg_set_global_property(make_prepare_flags_opts "${prepare_flags_opts}")
    z_vcpkg_make_prepare_flags(${prepare_flags_opts} ${escaping} C_COMPILER_NAME ccname FRONTEND_VARIANT_OUT frontend)

    if(DEFINED VCPKG_MAKE_BUILD_TRIPLET)
        set(arg_BUILD_TRIPLET "${VCPKG_MAKE_BUILD_TRIPLET}")
    endif()
    if(NOT DEFINED arg_BUILD_TRIPLET)
        z_vcpkg_make_get_configure_triplets(arg_BUILD_TRIPLET COMPILER_NAME ccname)
    endif()

    if(NOT arg_DISABLE_MSVC_WRAPPERS AND "${frontend}" STREQUAL "MSVC" )
        # Lets assume that wrappers are only required for MSVC like frontends.
        vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-make/wrappers")
    endif()

    vcpkg_make_get_shell(shell_var)
    set(shell_cmd "${shell_var}")

    if(arg_AUTOCONFIG)
      vcpkg_run_autoreconf("${shell_cmd}" "${src_dir}")
    endif()

    # Backup environment variables
    # CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJCXX R UPC Y 
    set(cm_FLAGS AR AS CCAS CC C CPP CXX FC FF GC LD LF LIBTOOL OBJC OBJXX R UPC Y RC)
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

        z_vcpkg_make_prepare_programs(configure_env ${prepare_flags_opts} CONFIG "${configup}")

        set(opts "")
        set(opts_cache "")
        if(NOT arg_DISABLE_DEFAULT_OPTIONS)
          z_vcpkg_make_default_path_and_configure_options(opts AUTOMAKE CONFIG "${configup}")
          vcpkg_list(APPEND arg_OPTIONS ${opts})
        endif()

        set(configure_path_from_wd "./${relative_build_path}/configure")

        foreach(cmd IN LISTS arg_PRE_CONFIGURE_CMAKE_COMMANDS)
            cmake_language(CALL ${cmd} ${configup})
        endforeach()

        vcpkg_make_run_configure(SHELL
                                    "${shell_cmd}"
                                 CONFIG  #configure_env
                                    "${configup}"
                                 CONFIGURE_ENV
                                    "${configure_env}"
                                 CONFIGURE_PATH
                                    "${configure_path_from_wd}"
                                 OPTIONS 
                                    ${opts_cache}
                                    ${arg_BUILD_TRIPLET}
                                    ${arg_OPTIONS} 
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