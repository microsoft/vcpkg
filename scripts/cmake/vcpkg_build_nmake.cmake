function(vcpkg_build_nmake)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ADD_BIN_TO_PATH;ENABLE_INSTALL;NO_DEBUG"
        "SOURCE_PATH;PROJECT_SUBPATH;PROJECT_NAME;LOGFILE_ROOT"
        "OPTIONS;OPTIONS_RELEASE;OPTIONS_DEBUG;PRERUN_SHELL;PRERUN_SHELL_DEBUG;PRERUN_SHELL_RELEASE;TARGET"
    )
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT DEFINED arg_SOURCE_PATH)
        message(FATAL_ERROR "SOURCE_PATH must be specified")
    endif()

    if(arg_NO_DEBUG)
        message(WARNING "NO_DEBUG argument to ${CMAKE_CURRENT_FUNCTION} is deprecated")
    endif()
    if(arg_ADD_BIN_TO_PATH)
        message(WARNING "ADD_BIN_TO_PATH argument to ${CMAKE_CURRENT_FUNCTION} is deprecated - it never did anything")
    endif()

    if(NOT VCPKG_HOST_IS_WINDOWS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} only support windows.")
    endif()

    if(NOT DEFINED arg_LOGFILE_ROOT)
        set(arg_LOGFILE_ROOT "build")
    endif()
    if(NOT DEFINED arg_PROJECT_NAME)
        set(arg_PROJECT_NAME makefile.vc)
    endif()
    if(NOT DEFINED arg_TARGET)
        vcpkg_list(SET arg_TARGET all)
    endif()

    find_program(NMAKE nmake REQUIRED)
    get_filename_component(NMAKE_EXE_PATH ${NMAKE} DIRECTORY)
    # Load toolchains
    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
    endif()
    include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    # Set needed env
    set(ENV{PATH} "$ENV{PATH};${NMAKE_EXE_PATH}")
    set(ENV{INCLUDE} "${CURRENT_INSTALLED_DIR}/include;$ENV{INCLUDE}")
    # Set make command and install command
    vcpkg_list(SET make_command ${NMAKE} /NOLOGO /G /U)
    vcpkg_list(SET make_opts_base -f "${arg_PROJECT_NAME}" ${arg_TARGET})
    if(arg_ENABLE_INSTALL)
        vcpkg_list(APPEND make_opts_base install)
    endif()


    # Add subpath to work directory
    if(DEFINED arg_PROJECT_SUBPATH)
        set(project_subpath "/${arg_PROJECT_SUBPATH}")
    else()
        set(project_subpath "")
    endif()

    vcpkg_backup_env_variables(VARS CL)
    cmake_path(NATIVE_PATH CURRENT_PACKAGES_DIR NORMALIZE install_dir_native)
    foreach(build_type IN ITEMS debug release)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL build_type)
            if(build_type STREQUAL "debug")
                # Generate obj dir suffix
                set(short_build_type "-dbg")
                # Add install command and arguments
                set(make_opts "${make_opts_base}")
                if (arg_ENABLE_INSTALL)
                    vcpkg_list(APPEND make_opts "INSTALLDIR=${install_dir_native}\\debug")
                endif()
                vcpkg_list(APPEND make_opts ${arg_OPTIONS} ${arg_OPTIONS_DEBUG})
                set(ENV{CL} "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG}")

                set(prerun_variable_name arg_PRERUN_SHELL_DEBUG)
            else()
                set(short_build_type "-rel")
                # Add install command and arguments
                set(make_opts "${make_opts_base}")
                if (arg_ENABLE_INSTALL)
                    vcpkg_list(APPEND make_opts "INSTALLDIR=${install_dir_native}")
                endif()
                vcpkg_list(APPEND make_opts ${arg_OPTIONS} ${arg_OPTIONS_RELEASE})

                set(ENV{CL} "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
                set(prerun_variable_name arg_PRERUN_SHELL_RELEASE)
            endif()

            set(triplet_and_build_type "${TARGET_TRIPLET}${short_build_type}")
            set(object_dir "${CURRENT_BUILDTREES_DIR}/${triplet_and_build_type}")

            file(REMOVE_RECURSE "${object_dir}")
            file(COPY "${arg_SOURCE_PATH}/" DESTINATION "${object_dir}")

            if(DEFINED arg_PRERUN_SHELL)
                message(STATUS "Prerunning ${triplet_and_build_type}")
                vcpkg_execute_required_process(
                    COMMAND ${arg_PRERUN_SHELL}
                    WORKING_DIRECTORY "${object_dir}${project_subpath}"
                    LOGNAME "prerun-${triplet_and_build_type}"
                )
            endif()
            if(DEFINED "${prerun_variable_name}")
                message(STATUS "Prerunning ${triplet_and_build_type}")
                vcpkg_execute_required_process(
                    COMMAND ${${prerun_variable_name}}
                    WORKING_DIRECTORY "${object_dir}${project_subpath}"
                    LOGNAME "prerun-specific-${triplet_and_build_type}"
                )
            endif()

            if (NOT arg_ENABLE_INSTALL)
                message(STATUS "Building ${triplet_and_build_type}")
            else()
                message(STATUS "Building and installing ${triplet_and_build_type}")
            endif()

            vcpkg_execute_build_process(
                COMMAND ${make_command} ${make_opts}
                WORKING_DIRECTORY "${object_dir}${project_subpath}"
                LOGNAME "${arg_LOGFILE_ROOT}-${triplet_and_build_type}"
            )

            vcpkg_restore_env_variables(VARS CL)
        endif()
    endforeach()
endfunction()
