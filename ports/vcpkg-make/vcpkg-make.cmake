# Be aware of https://github.com/microsoft/vcpkg/pull/31228
include_guard(GLOBAL)
include("${CMAKE_CURRENT_SOURCE_DIR}/vcpkg-make-common.cmake")

function(vcpkg_run_autoreconf)
# TODO:
# - Run autoreconf
# - Deal with tools like autopoint etc.
# does it make sense to parse configure.ac ?
endfunction()

function(vcpkg_run_bash)
# Prerun shell replacement
endfunction()

function(vcpkg_setup_win_msys)
# Get and put msys in the correct location in path
endfunction()

function(vcpkg_prepare_compile_flags)

endfunction()

function(vcpkg_prepare_win_compile_wrappers)
endfunction()


function(vcpkg_prepare_pkgconfig config)
# TODO
# Setup pkg-config paths
# Use cmake_language(DEFER to automatically call the restore command somehow ?
endfunction()

function(vcpkg_restore_pkgconfig)
# TODO
# restore variables
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
        "AUTOCONFIG;COPY_SOURCE;USE_WRAPPERS;NO_WRAPPERS;NO_CPP;DETERMINE_BUILD_TRIPLET"
        "SOURCE_PATH;CONFIGURE_SUBPATH;BUILD_TRIPLET"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;CONFIGURE_ENVIRONMENT_VARIABLES;CONFIG_DEPENDENT_ENVIRONMENT;ADDITIONAL_MSYS_PACKAGES"
    )

    z_vcpkg_unparsed_args(FATAL_ERROR)
    z_vcpkg_conflicting_args(arg_USE_WRAPPERS arg_NO_WRAPPERS)

    z_vcpkg_warn_path_with_spaces()

    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_setup_win_msys("${arg_ADDITIONAL_MSYS_PACKAGES}")
        if(arg_USE_WRAPPERS AND NOT arg_NO_WRAPPERS)
            vcpkg_prepare_win_compile_wrappers()
        endif()
    else()
    endif()

    if(arg_AUTOCONFIG)
        vcpkg_run_autoreconf("${arg_SOURCE_PATH}")
    endif()

    z_vcpkg_make_prepare_compiler_flags()
    z_vcpkg_make_prepare_environment_common()
    foreach(config IN LISTS build_configs)
        if(arg_COPY_SOURCE)
            vcpkg_copy_source("${config}")
        endif()
        vcpkg_make_run_configure("${config}")
    endforeach()

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