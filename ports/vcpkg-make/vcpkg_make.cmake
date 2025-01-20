# Be aware of https://github.com/microsoft/vcpkg/pull/31228
include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_make_common.cmake")

function(vcpkg_run_shell)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "" 
        "WORKING_DIRECTORY;LOGNAME"
        "SHELL;COMMAND;SAVE_LOG_FILES"
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)
    z_vcpkg_required_args(SHELL WORKING_DIRECTORY COMMAND LOGNAME)


    set(extra_opts "")
    if(arg_SAVE_LOG_FILES)
        set(extra_opts SAVE_LOG_FILES ${arg_SAVE_LOG_FILES})
    endif()

    # In the construction of the shell command, we need to handle environment variable assignments and configure options differently:
    #
    # 1. Environment variable assignments (e.g., CC, CXX, etc.):
    #    - These must not be quoted. 
    #    - If the environment variable names (e.g., CC, CXX, CC_FOR_BUILD) are quoted, the shell will treat them as part of the value, breaking the declaration.
    #    - For example, CC='/usr/bin/gcc' is valid, but "CC='/usr/bin/gcc'" would cause an error because the shell would try to use the entire quoted string as the variable name.
    #
    # 2. Options passed to the configure script:
    #    - The options should be quoted to ensure that any option containing spaces or special characters is treated as a single argument.
    #    - For instance, --prefix=/some path/with spaces would break if not quoted, as the shell would interpret each word as a separate argument.
    #    - By quoting the options like "--prefix=/some path/with spaces", we ensure they are passed correctly to the configure script as a single argument.
    #
    # The resulting command should look something like this:
    # V=1 CC='/Library/Developer/CommandLineTools/usr/bin/cc -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX14.4.sdk -arch arm64' 
    #     CXX='/Library/Developer/CommandLineTools/usr/bin/c++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX14.4.sdk -arch arm64' 
    #     CC_FOR_BUILD='/Library/Developer/CommandLineTools/usr/bin/cc -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX14.4.sdk -arch arm64'
    #     CPP_FOR_BUILD='/Library/Developer/CommandLineTools/usr/bin/cc -E -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX14.4.sdk -arch arm64' 
    #     CXX_FOR_BUILD='/Library/Developer/CommandLineTools/usr/bin/c++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX14.4.sdk -arch arm64' 
    #     ....
    #     ./../src/8bc98c3a0d-84009aba94.clean/configure "--enable-pic" "--disable-lavf" "--disable-swscale" "--disable-avs" ...
    vcpkg_list(JOIN arg_COMMAND " " arg_COMMAND)
    vcpkg_execute_required_process(
        COMMAND ${arg_SHELL} -c "${arg_COMMAND}"
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        LOGNAME "${arg_LOGNAME}"
        ${extra_opts}
    )
endfunction()

function(vcpkg_run_shell_as_build)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "" 
        "WORKING_DIRECTORY;LOGNAME"
        "SHELL;COMMAND;NO_PARALLEL_COMMAND;SAVE_LOG_FILES"
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)
    z_vcpkg_required_args(SHELL WORKING_DIRECTORY COMMAND LOGNAME)

    set(extra_opts "")
    if(arg_SAVE_LOG_FILES)
        set(extra_opts SAVE_LOG_FILES ${arg_SAVE_LOG_FILES})
    endif()

    list(JOIN arg_COMMAND " " cmd)
    list(JOIN arg_NO_PARALLEL_COMMAND " " no_par_cmd)
    if(NOT no_par_cmd STREQUAL "")
        set(no_par_cmd NO_PARALLEL_COMMAND ${arg_SHELL} -c "${no_par_cmd}")
    endif()
    vcpkg_execute_build_process(
        COMMAND ${arg_SHELL} -c "${cmd}"
        ${no_par_cmd}
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        LOGNAME "${arg_LOGNAME}"
        ${extra_opts}
    )
endfunction()

function(vcpkg_run_autoreconf shell_cmd work_dir)
    find_program(AUTORECONF NAMES autoreconf)
    if(NOT AUTORECONF)
        message(FATAL_ERROR "${PORT} currently requires the following programs from the system package manager:
        autoconf automake autoconf-archive
    On Debian and Ubuntu derivatives:
        sudo apt-get install autoconf automake autoconf-archive
    On recent Red Hat and Fedora derivatives:
        sudo dnf install autoconf automake autoconf-archive
    On Arch Linux and derivatives:
        sudo pacman -S autoconf automake autoconf-archive
    On Alpine:
        apk add autoconf automake autoconf-archive
    On macOS:
        brew install autoconf automake autoconf-archive\n")
    endif()
    message(STATUS "Generating configure for ${TARGET_TRIPLET}")
    vcpkg_run_shell(
        SHELL ${shell_cmd}
        COMMAND "${AUTORECONF}" -vfi
        WORKING_DIRECTORY "${work_dir}"
        LOGNAME "autoconf-${TARGET_TRIPLET}"
    )
    message(STATUS "Finished generating configure for ${TARGET_TRIPLET}")
endfunction()

function(vcpkg_make_setup_win_msys msys_out)
    list(APPEND msys_require_packages autoconf-wrapper automake-wrapper binutils libtool make which)
    vcpkg_insert_msys_into_path(msys PACKAGES ${msys_require_packages})
    find_program(PKGCONFIG NAMES pkgconf NAMES_PER_DIR PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf" NO_DEFAULT_PATH)
    set("${msys_out}" "${msys}" PARENT_SCOPE)
endfunction()

function(vcpkg_make_get_shell out_var)
    set(shell_options "")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        vcpkg_make_setup_win_msys(msys_root)
        set(shell_options --noprofile --norc --debug)
        set(shell_cmd "${msys_root}/usr/bin/bash.exe")
    endif()
    find_program(shell_cmd NAMES bash sh zsh REQUIRED)
    set("${out_var}" "${shell_cmd}" ${shell_options} PARENT_SCOPE)
endfunction()

function(z_vcpkg_make_get_configure_triplets out)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        ""
        "COMPILER_NAME"
        ""
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)
    # --build: the machine you are building on
    # --host: the machine you are building for
    # --target: the machine that CC will produce binaries for
    # https://stackoverflow.com/questions/21990021/how-to-determine-host-value-for-configure-when-using-cross-compiler
    # Only for ports using autotools so we can assume that they follow the common conventions for build/target/host
    z_vcpkg_make_determine_target_arch(TARGET_ARCH)
    z_vcpkg_make_determine_host_arch(BUILD_ARCH)

    set(build_triplet_opt "")
    if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_IS_WINDOWS)
        # This is required since we are running in a msys
        # shell which will be otherwise identified as ${BUILD_ARCH}-pc-msys
        set(build_triplet_opt "--build=${BUILD_ARCH}-pc-mingw32") 
    endif()

    set(host_triplet "")
    if(VCPKG_CROSSCOMPILING)
        if(VCPKG_TARGET_IS_WINDOWS)
            if(NOT TARGET_ARCH MATCHES "${BUILD_ARCH}" OR NOT CMAKE_HOST_WIN32)
                set(host_triplet_opt "--host=${TARGET_ARCH}-pc-mingw32")
            elseif(VCPKG_TARGET_IS_UWP)
                # Needs to be different from --build to enable cross builds.
                set(host_triplet_opt "--host=${TARGET_ARCH}-unknown-mingw32")
            endif()
        elseif(VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_OSX AND NOT "${TARGET_ARCH}" STREQUAL "${BUILD_ARCH}")
            set(host_triplet_opt "--host=${TARGET_ARCH}-apple-darwin")
        elseif(VCPKG_TARGET_IS_LINUX) 
            if("${arg_COMPILER_NAME}" MATCHES "([^\/]*)-gcc$" AND CMAKE_MATCH_1 AND NOT CMAKE_MATCH_1 MATCHES "^gcc")
                set(host_triplet_opt "--host=${CMAKE_MATCH_1}") # (Host activates crosscompilation; The name given here is just the prefix of the host tools for the target)
            endif()
        endif()
    endif()

    set(output "${build_triplet_opt};${host_triplet_opt}")
    string(STRIP "${output}" output)
    set("${out}" "${output}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_make_prepare_env config)
    cmake_parse_arguments(PARSE_ARGV 1 arg
        "ADD_BIN_TO_PATH"
        ""
        ""
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)
    # Used by CL 
    vcpkg_host_path_list(PREPEND ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include")
    # Used by GCC
    vcpkg_host_path_list(PREPEND ENV{C_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")
    vcpkg_host_path_list(PREPEND ENV{CPLUS_INCLUDE_PATH} "${CURRENT_INSTALLED_DIR}/include")
    
    # Flags should be set in the toolchain instead (Setting this up correctly requires a function named vcpkg_determined_cmake_compiler_flags which can also be used to setup CC and CXX etc.)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_backup_env_variables(VARS _CL_ _LINK_)
        # TODO: Should be CPP flags instead -> rewrite when vcpkg_determined_cmake_compiler_flags defined
        if(VCPKG_TARGET_IS_UWP)
            # Be aware that configure thinks it is crosscompiling due to: 
            # error while loading shared libraries: VCRUNTIME140D_APP.dll: 
            # cannot open shared object file: No such file or directory
            # IMPORTANT: The only way to pass linker flags through libtool AND the compile wrapper 
            # is to use the CL and LINK environment variables !!!
            # (This is due to libtool and compiler wrapper using the same set of options to pass those variables around)
            file(TO_CMAKE_PATH "$ENV{VCToolsInstallDir}" VCToolsInstallDir)
            set(_replacement -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_DEBUG}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG "${VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE "${VCPKG_DETECTED_CMAKE_CXX_FLAGS_RELEASE}")
            string(REPLACE "${_replacement}" "" VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE "${VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE}")
            set(ENV{_CL_} "$ENV{_CL_} -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\"")
            set(ENV{_LINK_} "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        endif()
    endif()

    # Setup environment
    set(ENV{CPPFLAGS} "${CPPFLAGS_${config}}")
    set(ENV{CPPFLAGS_FOR_BUILD} "${CPPFLAGS_${config}}")
    set(ENV{CFLAGS} "${CFLAGS_${config}}")
    set(ENV{CFLAGS_FOR_BUILD} "${CFLAGS_${config}}")
    set(ENV{CXXFLAGS} "${CXXFLAGS_${config}}")
    set(ENV{RCFLAGS} "${RCFLAGS_${config}}")
    set(ENV{LDFLAGS} "${LDFLAGS_${config}}")
    set(ENV{LDFLAGS_FOR_BUILD} "${LDFLAGS_${config}}")
    if(ARFLAGS_${config} AND NOT (arg_USE_WRAPPERS AND VCPKG_TARGET_IS_WINDOWS))
        # Target windows with wrappers enabled cannot forward ARFLAGS since it breaks the wrapper
        set(ENV{ARFLAGS} "${ARFLAGS_${config}}")
    endif()

    if(LINK_ENV_${config})
        set(ENV{_LINK_} "${LINK_ENV_${config}}")
    endif()

    vcpkg_list(APPEND lib_env_vars LIB LIBPATH LIBRARY_PATH)
    foreach(lib_env_var IN LISTS lib_env_vars)
        if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${config}}/lib")
            vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${CURRENT_INSTALLED_DIR}${path_suffix_${config}}/lib")
        endif()
        if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${config}}/lib/manual-link")
            vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${CURRENT_INSTALLED_DIR}${path_suffix_${config}}/lib/manual-link")
        endif()
    endforeach()
endfunction()

function(z_vcpkg_make_restore_env)
    # Only variables which are inspected in vcpkg_make_prepare_env need to be restored here.
    # Rest is restored add the end of configure. 
    vcpkg_restore_env_variables(VARS 
         LIBRARY_PATH LIB LIBPATH
         PATH
    )
endfunction()

function(vcpkg_make_run_configure)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ADD_BIN_TO_PATH" 
        "CONFIG;SHELL;WORKING_DIRECTORY;CONFIGURE_PATH;CONFIGURE_ENV"
        "OPTIONS"
    )
    z_vcpkg_unparsed_args(FATAL_ERROR)
    z_vcpkg_required_args(SHELL CONFIG WORKING_DIRECTORY CONFIGURE_PATH)

    vcpkg_prepare_pkgconfig("${arg_CONFIG}")

    set(prepare_env_opts "")

    z_vcpkg_make_prepare_env("${arg_CONFIG}" ${prepare_env_opts})

    vcpkg_list(SET tmp)
    foreach(element IN LISTS arg_OPTIONS)
        string(REPLACE [["]] [[\"]] element "${element}")
        vcpkg_list(APPEND tmp "\"${element}\"")
    endforeach()
    vcpkg_list(JOIN tmp " " "arg_OPTIONS")
    set(command ${arg_CONFIGURE_ENV} ${arg_CONFIGURE_PATH} ${arg_OPTIONS})

    message(STATUS "Configuring ${TARGET_TRIPLET}-${suffix_${arg_CONFIG}}")
    vcpkg_run_shell(
        WORKING_DIRECTORY "${arg_WORKING_DIRECTORY}"
        LOGNAME "config-${TARGET_TRIPLET}-${suffix_${arg_CONFIG}}"
        SAVE_LOG_FILES config.log
        SHELL ${arg_SHELL}
        COMMAND V=1 ${command}
    )
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(GLOB_RECURSE libtool_files "${arg_WORKING_DIRECTORY}*/libtool")
        foreach(lt_file IN LISTS libtool_files)
            file(READ "${lt_file}" _contents)
            string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
            file(WRITE "${lt_file}" "${_contents}")
        endforeach()
    endif()
    z_vcpkg_make_restore_env()
    vcpkg_restore_pkgconfig()
endfunction()
