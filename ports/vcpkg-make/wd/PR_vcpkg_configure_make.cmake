
function(vcpkg_configure_make)
    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "AUTOCONFIG;SKIP_CONFIGURE;COPY_SOURCE;DISABLE_VERBOSE_FLAGS;NO_ADDITIONAL_PATHS;ADD_BIN_TO_PATH;NO_DEBUG;USE_WRAPPERS;NO_WRAPPERS;DETERMINE_BUILD_TRIPLET"
        "SOURCE_PATH;PROJECT_SUBPATH;PRERUN_SHELL;BUILD_TRIPLET"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE;CONFIGURE_ENVIRONMENT_VARIABLES;CONFIG_DEPENDENT_ENVIRONMENT;ADDITIONAL_MSYS_PACKAGES"
    )

    set(configure_env "V=1")

    # Pre-processing windows configure requirements
    if (VCPKG_TARGET_IS_WINDOWS)
        # Other maybe interesting variables to control
        # COMPILE This is the command used to actually compile a C source file. The file name is appended to form the complete command line. 
        # LINK This is the command used to actually link a C program.
        # CXXCOMPILE The command used to actually compile a C++ source file. The file name is appended to form the complete command line. 
        # CXXLINK  The command used to actually link a C++ program. 

        # Variables not correctly detected by configure. In release builds.
        list(APPEND arg_OPTIONS gl_cv_double_slash_root=yes
                                 ac_cv_func_memmove=yes)
        #list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all) # Just ignore libtool checks 
        if(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]64$")
            list(APPEND arg_OPTIONS gl_cv_host_cpu_c_abi=no)
            # Currently needed for arm64 because objdump yields: "unrecognised machine type (0xaa64) in Import Library Format archive"
            list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all)
        elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "^[Aa][Rr][Mm]$")
            # Currently needed for arm because objdump yields: "unrecognised machine type (0x1c4) in Import Library Format archive"
            list(APPEND arg_OPTIONS lt_cv_deplibs_check_method=pass_all)
        endif()
    endif()
    z_vcpkg_configure_make_common_definitions()

    # Cleanup previous build dirs
    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_RELEASE}"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_name_DEBUG}"
                        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    file(RELATIVE_PATH relative_build_path "${CURRENT_BUILDTREES_DIR}" "${arg_SOURCE_PATH}/${arg_PROJECT_SUBPATH}")

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
            # Can somebody please check if CMake's compiler flags for UWP are correct?
            set(ENV{_CL_} "$ENV{_CL_} -FU\"${VCToolsInstallDir}/lib/x86/store/references/platform.winmd\"")
            set(ENV{_LINK_} "$ENV{_LINK_} ${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES} ${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
        endif()
    endif()

    # Remove outer quotes from cmake variables which will be forwarded via makefile/shell variables
    # substituted into makefile commands (e.g. Android NDK has "--sysroot=...")
    separate_arguments(c_libs_list NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_C_STANDARD_LIBRARIES}")
    separate_arguments(cxx_libs_list NATIVE_COMMAND "${VCPKG_DETECTED_CMAKE_CXX_STANDARD_LIBRARIES}")
    list(REMOVE_ITEM cxx_libs_list ${c_libs_list})
    set(all_libs_list ${cxx_libs_list} ${c_libs_list})
    #Do lib list transformation from name.lib to -lname if necessary
    set(x_vcpkg_transform_libs ON)
    if(VCPKG_TARGET_IS_UWP)
        set(x_vcpkg_transform_libs OFF)
        # Avoid libtool choke: "Warning: linker path does not have real file for library -lWindowsApp."
        # The problem with the choke is that libtool always falls back to built a static library even if a dynamic was requested. 
        # Note: Env LIBPATH;LIB are on the search path for libtool by default on windows. 
        # It even does unix/dos-short/unix transformation with the path to get rid of spaces. 
    endif()
    if(x_vcpkg_transform_libs)
        list(TRANSFORM all_libs_list REPLACE "[.](dll[.]lib|lib|a|so)$" "")
        if(VCPKG_TARGET_IS_WINDOWS)
            list(REMOVE_ITEM all_libs_list "uuid")
        endif()
        list(TRANSFORM all_libs_list REPLACE "^([^-].*)" "-l\\1")
        if(VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            # libtool must be told explicitly that there is no dynamic linkage for uuid.
            # The "-Wl,..." syntax is understood by libtool and gcc, but no by ld.
            list(TRANSFORM all_libs_list REPLACE "^-luuid\$" "-Wl,-Bstatic,-luuid,-Bdynamic")
        endif()
    endif()
    if(all_libs_list)
        list(JOIN all_libs_list " " all_libs_string)
        if(DEFINED ENV{LIBS})
            set(ENV{LIBS} "$ENV{LIBS} ${all_libs_string}")
        else()
            set(ENV{LIBS} "${all_libs_string}")
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug" AND NOT arg_NO_DEBUG)
        list(APPEND all_buildtypes DEBUG)
        z_vcpkg_configure_make_process_flags(DEBUG)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        list(APPEND all_buildtypes RELEASE)
        z_vcpkg_configure_make_process_flags(RELEASE)
    endif()

    list(FILTER z_vcm_all_flags INCLUDE REGEX " ") # TODO: Figure out where this warning belongs to. 
    if(z_vcm_all_flags)
        list(REMOVE_DUPLICATES z_vcm_all_flags)
        list(JOIN z_vcm_all_flags "\n   " flags)
        message(STATUS "Warning: Arguments with embedded space may be handled incorrectly by configure:\n   ${flags}")
    endif()

    foreach(var IN ITEMS arg_OPTIONS arg_OPTIONS_RELEASE arg_OPTIONS_DEBUG)
        vcpkg_list(SET tmp)
        foreach(element IN LISTS "${var}")
            string(REPLACE [["]] [[\"]] element "${element}")
            vcpkg_list(APPEND tmp "\"${element}\"")
        endforeach()
        vcpkg_list(JOIN tmp " " "${var}")
    endforeach()

    foreach(current_buildtype IN LISTS all_buildtypes)
        foreach(ENV_VAR ${arg_CONFIG_DEPENDENT_ENVIRONMENT})
            if(DEFINED ENV{${ENV_VAR}})
                set(backup_config_${ENV_VAR} "$ENV{${ENV_VAR}}")
            endif()
            set(ENV{${ENV_VAR}} "${${ENV_VAR}_${current_buildtype}}")
        endforeach()

        # Setup environment
        set(ENV{CPPFLAGS} "${CPPFLAGS_${current_buildtype}}")
        set(ENV{CPPFLAGS_FOR_BUILD} "${CPPFLAGS_${current_buildtype}}")
        set(ENV{CFLAGS} "${CFLAGS_${current_buildtype}}")
        set(ENV{CFLAGS_FOR_BUILD} "${CFLAGS_${current_buildtype}}")
        set(ENV{CXXFLAGS} "${CXXFLAGS_${current_buildtype}}")
        #set(ENV{CXXFLAGS_FOR_BUILD} "${CXXFLAGS_${current_buildtype}}") -> doesn't exist officially
        set(ENV{RCFLAGS} "${VCPKG_DETECTED_CMAKE_RC_FLAGS_${current_buildtype}}")
        set(ENV{LDFLAGS} "${LDFLAGS_${current_buildtype}}")
        set(ENV{LDFLAGS_FOR_BUILD} "${LDFLAGS_${current_buildtype}}")
        if(ARFLAGS_${current_buildtype} AND NOT (arg_USE_WRAPPERS AND VCPKG_TARGET_IS_WINDOWS))
            # Target windows with wrappers enabled cannot forward ARFLAGS since it breaks the wrapper
            set(ENV{ARFLAGS} "${ARFLAGS_${current_buildtype}}")
        endif()

        # VCPKG_ABIFLAGS isn't standard, but can be useful to reinject these flags into other variables
        set(ENV{VCPKG_ABIFLAGS} "${ABIFLAGS_${current_buildtype}}")
        if(ABIFLAGS_${current_buildtype})
            # libtool removes some flags which are needed for configure tests.
            set(ENV{CC} "$ENV{CC} ${ABIFLAGS_${current_buildtype}}")
            set(ENV{CXX} "$ENV{CXX} ${ABIFLAGS_${current_buildtype}}")
            set(ENV{CC_FOR_BUILD} "$ENV{CC_FOR_BUILD} ${ABIFLAGS_${current_buildtype}}")
            set(ENV{CXX_FOR_BUILD} "$ENV{CXX_FOR_BUILD} ${ABIFLAGS_${current_buildtype}}")
        endif()

        if(LINK_ENV_${current_buildtype})
            set(link_config_backup "$ENV{_LINK_}")
            set(ENV{_LINK_} "${LINK_ENV_${current_buildtype}}")
        else()
            unset(link_config_backup)
        endif()

        vcpkg_list(APPEND lib_env_vars LIB LIBPATH LIBRARY_PATH) # LD_LIBRARY_PATH)
        foreach(lib_env_var IN LISTS lib_env_vars)
            if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib")
                vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib")
            endif()
            if(EXISTS "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib/manual-link")
                vcpkg_host_path_list(PREPEND ENV{${lib_env_var}} "${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/lib/manual-link")
            endif()
        endforeach()
        unset(lib_env_vars)

        set(command "${base_cmd}" -c "${configure_env} ./${relative_build_path}/configure ${arg_BUILD_TRIPLET} ${arg_OPTIONS} ${arg_OPTIONS_${current_buildtype}}")
        
        if(arg_ADD_BIN_TO_PATH)
            set(path_backup $ENV{PATH})
            vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}${path_suffix_${current_buildtype}}/bin")
        endif()
        debug_message("Configure command:'${command}'")
        if (NOT arg_SKIP_CONFIGURE)
            message(STATUS "Configuring ${TARGET_TRIPLET}-${short_name_${current_buildtype}}")
            vcpkg_execute_required_process(
                COMMAND ${command}
                WORKING_DIRECTORY "${target_dir}"
                LOGNAME "config-${TARGET_TRIPLET}-${short_name_${current_buildtype}}"
                SAVE_LOG_FILES config.log
            )
            if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
                file(GLOB_RECURSE libtool_files "${target_dir}*/libtool")
                foreach(lt_file IN LISTS libtool_files)
                    file(READ "${lt_file}" _contents)
                    string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
                    file(WRITE "${lt_file}" "${_contents}")
                endforeach()
            endif()
        endif()
        z_vcpkg_restore_pkgconfig_path()
        
        if(DEFINED link_config_backup)
            set(ENV{_LINK_} "${link_config_backup}")
        endif()
        
        if(arg_ADD_BIN_TO_PATH)
            set(ENV{PATH} "${path_backup}")
        endif()
        # Restore environment (config dependent)
        foreach(ENV_VAR IN LISTS ${arg_CONFIG_DEPENDENT_ENVIRONMENT})
            if(backup_config_${ENV_VAR})
                set(ENV{${ENV_VAR}} "${backup_config_${ENV_VAR}}")
            else()
                unset(ENV{${ENV_VAR}})
            endif()
        endforeach()
    endforeach()

    # Export matching make program for vcpkg_build_make (cache variable)
    if(CMAKE_HOST_WIN32 AND MSYS_ROOT)
        find_program(Z_VCPKG_MAKE make PATHS "${MSYS_ROOT}/usr/bin" NO_DEFAULT_PATH REQUIRED)
    elseif(VCPKG_HOST_IS_FREEBSD OR VCPKG_HOST_IS_OPENBSD)
        find_program(Z_VCPKG_MAKE gmake REQUIRED)
    else()
        find_program(Z_VCPKG_MAKE make REQUIRED)
    endif()

    set(_VCPKG_PROJECT_SOURCE_PATH ${arg_SOURCE_PATH} PARENT_SCOPE)
    set(_VCPKG_PROJECT_SUBPATH ${arg_PROJECT_SUBPATH} PARENT_SCOPE)
    set(_VCPKG_MAKE_NO_DEBUG ${arg_NO_DEBUG} PARENT_SCOPE)
endfunction()