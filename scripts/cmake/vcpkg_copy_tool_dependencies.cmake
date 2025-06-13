# Given a list of targets, try to resolve all of their transitive dependencies and deploy them to the target directory.
# Success measures are a bit dubious for this kind of operation because of loading mechanisms that do not require that
# each and every dependency need be in the same directory as your target. So, some dependencies are not required to be
# 'resolved' in this context for the target to still work properly. It is a case-by-case basis. Sometimes, a target will
# require special handling to ensure it works properly; that logic should be added to the Special Handling region.
# param TARGET_OBJECT_PATHS - list<string>, required. list of target object paths to resolve.
#   e.g. "/path/to/myproject.exe;/some/path/somedll.dll;/my/dependency/libthing.dll"
#
# param ADDITIONAL_SEARCH_PATHS - list<string>, optional. additional search paths to use when resolving dependencies
# param RESOLVED_DEPENDENCIES_RESULT - list<string>, optional, output variable. list of resolved dependencies
# param UNRESOLVED_DEPENDENCIES_RESULT - list<string>, optional, output variable. list of unresolved dependencies
function(vcpkg_resolve_deploy_object_dependencies)

    message(STATUS "vcpkg_resolve_deploy_object_dependencies: Resolving dependencies for targets: ${ARGN}")

    set(one_value_args_ RESOLVED_DEPENDENCIES_RESULT UNRESOLVED_DEPENDENCIES_RESULT)
    set(multi_value_args_ TARGET_OBJECT_PATHS ADDITIONAL_SEARCH_PATHS)
    cmake_parse_arguments(vcpkg_resolve_deploy_object_dependencies "" "${one_value_args_}" "${multi_value_args_}" ${ARGN})

    message(STATUS "vcpkg_resolve_deploy_object_dependencies: ADDITIONAL_SEARCH_PATHS: ${vcpkg_resolve_deploy_object_dependencies_ADDITIONAL_SEARCH_PATHS}")

    set(search_paths_ ${vcpkg_resolve_deploy_object_dependencies_ADDITIONAL_SEARCH_PATHS})
    set(to_be_resolved_stack_ "")

    foreach (target_ IN LISTS vcpkg_resolve_deploy_object_dependencies_TARGET_OBJECT_PATHS)
        get_filename_component(target_directory_ "${target_}" DIRECTORY)
        list(APPEND search_paths_ "${target_directory_}")
    endforeach()
    list(REMOVE_DUPLICATES search_paths_)

    set(to_be_resolved_list_ "${vcpkg_resolve_deploy_object_dependencies_TARGET_OBJECT_PATHS}")
    list(REMOVE_DUPLICATES to_be_resolved_list_)

    set(resolved_files_ "")
    set(unresolved_files_ "")
    set(processed_files_ "")

    # Get dependencies of each of the targets in the list.
    # If we're dealing with a special case, more items may be appended to the list.
    set(to_be_resolved_stack_ "${to_be_resolved_list_}")
    message(STATUS "vcpkg_resolve_deploy_object_dependencies: Initial targets to resolve: ${to_be_resolved_list_}")
    while (to_be_resolved_stack_)

        list(POP_FRONT to_be_resolved_stack_ current_target_)

        message(STATUS "vcpkg_resolve_deploy_object_dependencies: Processing target: ${current_target_}")

        if ("${current_target_}" IN_LIST processed_files_)
            message(STATUS "vcpkg_resolve_deploy_object_dependencies: ${current_target_} already processed, skipping")
            continue()
        endif()

        get_filename_component(current_target_filename_ ${current_target_} NAME)
        get_filename_component(current_target_extension_ ${current_target_} EXT)
        string(TOLOWER "${current_target_extension_}" current_target_extension_)
        vcpkg_make_cmake_identifier(INPUT "${current_target_filename_}" OUTPUT_VARIABLE current_var_name_)

        # applocal.ps1 asserts that current_target_dir_ is some /bin directory.
        get_filename_component(current_target_dir_ ${current_target_} DIRECTORY)
        cmake_path(GET current_target_dir_ PARENT_PATH current_target_install_root_dir_)

        # If the the directory name is debug or debug/ (trailing slash)
        set(current_target_install_root_dir_is_debug_ FALSE)
        if (current_target_install_root_dir_ MATCHES "[/\\]debug[/\\]?$")
            set(current_target_install_root_dir_is_debug_ TRUE)
        endif()

        message(STATUS "vcpkg_resolve_deploy_object_dependencies: Gathering dependencies for ${current_target_filename_}")

        # Ensure that the target file exists, sanity check
        unset(find_file_result_)
        find_file(
            find_file_result_
            NAMES "${current_target_filename_}"
            PATHS ${search_paths_}
            PATH_SUFFIXES bin
            NO_DEFAULT_PATH
            NO_CACHE
        )

        list(APPEND processed_files_ "${current_target_}")

        if (find_file_result_ STREQUAL "find_file_result_-NOTFOUND")
            message(STATUS "vcpkg_resolve_deploy_object_dependencies: Could not validate existence of: ${current_target_}. Skipping.")
            continue()
        endif()
        # Otherwise, mark as resolved - keep digging

        # region Special Handling
        # Some projects deploy tools that have dependencies that wont resolve with GET_RUNTIME_DEPENDENCIES.
        # Check if we are dealing with one of those, if so, handle it.
        # Note to implementers: If your project requires special handling, add it in this region.

        detect_dependency_qt_module(
            TARGET_OBJECT_PATH "${find_file_result_}"
            IS_DETECTED_RESULT is_detected_
        )
        if (is_detected_)
            message(STATUS "vcpkg_resolve_deploy_object_dependencies: Found Qt module in ${find_file_result_}. Handling with care.")
            cmake_path(APPEND current_target_install_root_dir_ "plugins" OUTPUT_VARIABLE qt_plugins_dir_)
            deploy_dependencies_qt_module(
                TARGET_OBJECT_PATH "${find_file_result_}"
                QT_PLUGINS_DIR "${qt_plugins_dir_}"
                DEPLOYED_FILES_RESULT deployed_files_list_
                DEPENDENCIES_TO_RESOLVE_RESULT to_resolve_list_
            )
            foreach (file_ IN LISTS to_resolve_list_)
                if (NOT file_ IN_LIST processed_files_)
                    list(APPEND to_be_resolved_list_ "${file_}")
                    list(APPEND to_be_resolved_stack_ "${file_}")
                endif()
            endforeach()
        endif()

        detect_dependency_OpenNI2(
            TARGET_OBJECT_PATH "${find_file_result_}"
            IS_DETECTED_RESULT is_detected_
        )
        if (is_detected_)
            message(STATUS "vcpkg_resolve_deploy_object_dependencies: Found OpenNI2 module in ${find_file_result_}. Handling with care.")
            deploy_dependencies_OpenNI2(
                TARGET_OBJECT_PATH "${find_file_result_}"
                OPEN_NI2_INSTALLED_DIR "${current_target_install_root_dir_}"
                DEPLOYED_FILES_RESULT deployed_files_list_
                DEPENDENCIES_TO_RESOLVE_RESULT to_resolve_list_
            )
            foreach (file_ IN LISTS to_resolve_list_)
                if (NOT file_ IN_LIST processed_files_)
                    list(APPEND to_be_resolved_list_ "${file_}")
                    list(APPEND to_be_resolved_stack_ "${file_}")
                endif()
            endforeach()
        endif()

        detect_dependency_magnum(
            TARGET_OBJECT_PATH "${find_file_result_}"
            IS_DETECTED_RESULT is_detected_
        )
        if (is_detected_)
            message(STATUS "vcpkg_resolve_deploy_object_dependencies: Found Magnum module in ${find_file_result_}. Handling with care.")
            if (current_target_install_root_dir_is_debug_)
                cmake_path(APPEND current_target_install_root_dir_ "bin" "magnum-d" OUTPUT_VARIABLE magnum_plugins_dir_)
            else()
                cmake_path(APPEND current_target_install_root_dir_ "bin" "magnum" OUTPUT_VARIABLE magnum_plugins_dir_)
            endif()
            deploy_dependencies_magnum(
                TARGET_OBJECT_PATH "${find_file_result_}"
                MAGNUM_PLUGINS_DIR "${magnum_plugins_dir_}"
                DEPLOYED_FILES_RESULT deployed_files_list_
                DEPENDENCIES_TO_RESOLVE_RESULT to_resolve_list_
            )
            foreach (file_ IN LISTS to_resolve_list_)
                if (NOT file_ IN_LIST processed_files_)
                    list(APPEND to_be_resolved_list_ "${file_}")
                    list(APPEND to_be_resolved_stack_ "${file_}")
                endif()
            endforeach()
        endif()

        detect_dependency_azure_kinect_sensor_sdk(
            TARGET_OBJECT_PATH "${find_file_result_}"
            IS_DETECTED_RESULT is_detected_
        )
        if (is_detected_)
            message(STATUS "vcpkg_resolve_deploy_object_dependencies: Found Azure Kinect Sensor SDK in ${find_file_result_}. Handling with care.")
            deploy_dependencies_azure_kinect_sensor_sdk(
                TARGET_OBJECT_PATH "${find_file_result_}"
                KINECT_INSTALLED_DIR "${current_target_install_root_dir_}"
                DEPLOYED_FILES_RESULT deployed_files_list_
                DEPENDENCIES_TO_RESOLVE_RESULT to_resolve_list_
            )
            foreach (file_ IN LISTS to_resolve_list_)
                if (NOT file_ IN_LIST processed_files_)
                    list(APPEND to_be_resolved_list_ "${file_}")
                    list(APPEND to_be_resolved_stack_ "${file_}")
                endif()
            endforeach()
        endif()
        list(REMOVE_DUPLICATES to_be_resolved_list_)

        # endregion Special Handling

        # Temporarily suppress warnings
        set(original_no_dev_warnings_ "$CACHE{CMAKE_SUPPRESS_DEVELOPER_WARNINGS}")
        set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS ON CACHE INTERNAL "" FORCE)

        message(STATUS "vcpkg_resolve_deploy_object_dependencies: Searching for dependencies in ${search_paths_}")
        if (current_target_extension_ MATCHES "\\.dll$|\\.pyd$")
            file(GET_RUNTIME_DEPENDENCIES
                LIBRARIES "${find_file_result_}"
                DIRECTORIES ${search_paths_}
                RESOLVED_DEPENDENCIES_VAR resolved_runtime_dependencies_
                UNRESOLVED_DEPENDENCIES_VAR unresolved_runtime_dependencies_
            )
            message(STATUS "vcpkg_resolve_deploy_object_dependencies: Resolved dependencies for library ${current_target_filename_}")
        elseif (current_target_extension_ MATCHES "\\.exe$")
            message(STATUS "vcpkg_resolve_deploy_object_dependencies: Resolving dependencies for executable ${current_target_filename_}- search paths: ${search_paths_}")
            file(GET_RUNTIME_DEPENDENCIES
                EXECUTABLES "${find_file_result_}"
                DIRECTORIES ${search_paths_}
                RESOLVED_DEPENDENCIES_VAR resolved_runtime_dependencies_
                UNRESOLVED_DEPENDENCIES_VAR unresolved_runtime_dependencies_
            )
            message(STATUS "vcpkg_resolve_deploy_object_dependencies: Resolved dependencies for executable ${current_target_filename_}")
        else()
            message(WARNING "vcpkg_resolve_deploy_object_dependencies: Unsupported file type for ${current_target_filename_}. Skipping.")
            set(resolved_runtime_dependencies_ "")
            set(unresolved_runtime_dependencies_ "")
        endif()

        # Restore warnings
        set(CMAKE_SUPPRESS_DEVELOPER_WARNINGS ${original_no_dev_warnings_} CACHE INTERNAL "" FORCE)

        list(APPEND resolved_files_ "${resolved_runtime_dependencies_}")
        list(REMOVE_DUPLICATES resolved_files_)
        list(APPEND unresolved_files_ "${unresolved_runtime_dependencies_}")
        list(REMOVE_DUPLICATES unresolved_files_)

        set(system_resolved_dependencies_ "${resolved_runtime_dependencies_}")
        list(FILTER system_resolved_dependencies_ INCLUDE REGEX ".*[Ss][Yy][Ss][Tt][Ee][Mm]32.*|.*[Ss][Yy][Ss][Ww][Oo][Ww]64.*")

        set(nonsystem_resolved_dependencies_ "${resolved_runtime_dependencies_}")
        list(FILTER nonsystem_resolved_dependencies_ EXCLUDE REGEX ".*[Ss][Yy][Ss][Tt][Ee][Mm]32.*|.*[Ss][Yy][Ss][Ww][Oo][Ww]64.*")

        set(${current_var_name_}_system_resolved_dependencies_ "${system_resolved_dependencies_}")
        set(${current_var_name_}_nonsystem_resolved_dependencies_ "${nonsystem_resolved_dependencies_}")
        set(${current_var_name_}_resolved_dependencies_ "${resolved_runtime_dependencies_}")
        list(REMOVE_DUPLICATES ${current_var_name_}_resolved_dependencies_)
        set(${current_var_name_}_unresolved_dependencies_ "${unresolved_runtime_dependencies_}")
        list(REMOVE_DUPLICATES ${current_var_name_}_unresolved_dependencies_)

    endwhile()

    message(STATUS "vcpkg_resolve_deploy_object_dependencies: Finished resolving dependencies for targets: ${to_be_resolved_list_}")

    # Reporting section, for debugging and info purposes
    # Code looks ugly to make the output look pretty
    foreach (target_ IN LISTS to_be_resolved_list_)

        get_filename_component(target_filename_ ${target_} NAME)
        vcpkg_make_cmake_identifier(INPUT "${target_filename_}" OUTPUT_VARIABLE target_var_name_)
        set(target_resolved_dependencies_ "${${target_var_name_}_resolved_dependencies_}") # Will be a full path to file
        set(target_unresolved_dependencies_ "${${target_var_name_}_unresolved_dependencies_}")
        set(target_system_resolved_dependencies_ "${${target_var_name_}_system_resolved_dependencies_}")
        set(target_nonsystem_resolved_dependencies_ "${${target_var_name_}_nonsystem_resolved_dependencies_}")
        set(resolved_dependency_max_string_length_ 0)
        set(unresolved_dependency_max_string_length_ 0)

        foreach (resolved_ IN LISTS target_system_resolved_dependencies_)
            get_filename_component(resolved_filename_ "${resolved_}" NAME)
            string(LENGTH "${resolved_filename_}" length_)
            math(EXPR length_ "${length_} + 9") # +9 for " [SYSTEM]"
            vcpkg_max(VALUES "${length_}" "${resolved_dependency_max_string_length_}"
                OUTPUT_VARIABLE resolved_dependency_max_string_length_
            )
        endforeach()
        foreach (resolved_ IN LISTS target_nonsystem_resolved_dependencies_)
            get_filename_component(resolved_filename_ "${resolved_}" NAME)
            string(LENGTH "${resolved_filename_}" length_)
            vcpkg_max(VALUES "${length_}" "${resolved_dependency_max_string_length_}"
                    OUTPUT_VARIABLE resolved_dependency_max_string_length_
            )
        endforeach()

        foreach (unresolved_ IN LISTS target_unresolved_dependencies_)
            string(LENGTH "${unresolved_}" length_)
            vcpkg_max(VALUES "${length_}" "${unresolved_dependency_max_string_length_}"
                OUTPUT_VARIABLE unresolved_dependency_max_string_length_
            )
        endforeach()

        message(STATUS "vcpkg_resolve_deploy_object_dependencies: ${target_filename_} - Dependency Resolution Summary")
        message(STATUS "  Resolved Dependencies:")
        foreach (resolved_ IN LISTS target_nonsystem_resolved_dependencies_)
            get_filename_component(resolved_filename_ "${resolved_}" NAME)
            string(LENGTH "${resolved_filename_}" dependency_length_)
            math(EXPR string_padding_length_ "${resolved_dependency_max_string_length_} - ${dependency_length_}")
            set(temp_str_ "    ${resolved_filename_}")
            foreach (it RANGE ${string_padding_length_})
                string(APPEND temp_str_ " ")
            endforeach()
            string(APPEND temp_str_ "-> ${resolved_}")
            message(STATUS "${temp_str_}")
        endforeach()

        foreach (resolved_ IN LISTS target_system_resolved_dependencies_)
            get_filename_component(resolved_filename_ "${resolved_}" NAME)
            string(LENGTH "${resolved_filename_}" dependency_length_)
            math(EXPR string_padding_length_ "${resolved_dependency_max_string_length_} - ${dependency_length_} - 9") # -9 for " [SYSTEM]"
            set(temp_str_ "    ${resolved_filename_}")
            foreach (it RANGE ${string_padding_length_})
                string(APPEND temp_str_ " ")
            endforeach()
            string(APPEND temp_str_ "[SYSTEM] -> ${resolved_}")
            message(STATUS "${temp_str_}")
        endforeach()

        message(STATUS "  Unresolved Dependencies:")
        foreach (unresolved_ IN LISTS target_unresolved_dependencies_)
            string(LENGTH "${unresolved_}" dependency_length_)
            math(EXPR string_padding_length_ "${unresolved_dependency_max_string_length_} - ${dependency_length_}")
            vcpkg_make_cmake_identifier(INPUT "${unresolved_}" OUTPUT_VARIABLE dependency_varname_)
            set(temp_str_ "    ${unresolved_}")
            foreach (it RANGE ${string_padding_length_})
                string(APPEND temp_str_ " ")
            endforeach()
            string(APPEND temp_str_ "-> NOT FOUND")
            message(STATUS "${temp_str_}")
        endforeach()

    endforeach()

    message(STATUS "vcpkg_resolve_deploy_object_dependencies: Copying resolved dependencies to their target directories")
    foreach(target_ IN LISTS to_be_resolved_list_)

        get_filename_component(target_filename_ ${target_} NAME)
        get_filename_component(target_dir_ ${target_} DIRECTORY)

        message(STATUS "vcpkg_resolve_deploy_object_dependencies: Copying dependencies for ${target_filename_}")

        vcpkg_make_cmake_identifier(INPUT "${target_filename_}" OUTPUT_VARIABLE target_var_name_)
        set(target_resolved_dependencies_ "${${target_var_name_}_resolved_dependencies_}")
        set(target_system_resolved_dependencies_ "${${target_var_name_}_system_resolved_dependencies_}")
        set(target_nonsystem_resolved_dependencies_ "${${target_var_name_}_nonsystem_resolved_dependencies_}")

        foreach (dependency_ IN LISTS target_nonsystem_resolved_dependencies_)
            get_filename_component(dependency_dir_ "${dependency_}" DIRECTORY)
            get_filename_component(dependency_filename_ "${dependency_}" NAME)
            cmake_path(APPEND target_dir_ "${dependency_filename_}" OUTPUT_VARIABLE new_location_)
            unset(find_file_result_)
            find_file(find_file_result_ NO_CACHE NO_DEFAULT_PATH
                NAMES "${dependency_filename_}"
                PATHS "${target_dir_}"
            )
            if (NOT find_file_result_ STREQUAL "find_file_result_-NOTFOUND")
                message(STATUS "vcpkg_resolve_deploy_object_dependencies: ${target_filename_} dependency - ${dependency_filename_} already exists at ${new_location_}. Will not copy.")
                continue()
            endif()

            file(COPY_FILE "${dependency_}" "${new_location_}" RESULT copy_result_ INPUT_MAY_BE_RECENT)
            if (NOT copy_result_ EQUAL 0)
                message(WARNING "vcpkg_resolve_deploy_object_dependencies: Could not copy ${dependency_} to ${new_location_}.")
                continue()
            endif()
        endforeach()
    endforeach()

    if (vcpkg_resolve_deploy_object_dependencies_RESOLVED_DEPENDENCIES_RESULT)
        list(REMOVE_DUPLICATES resolved_files_)
        set(${vcpkg_resolve_deploy_object_dependencies_RESOLVED_DEPENDENCIES_RESULT} "${resolved_files_}" PARENT_SCOPE)
    endif()
    if (vcpkg_resolve_deploy_object_dependencies_UNRESOLVED_DEPENDENCIES_RESULT)
        list(REMOVE_DUPLICATES unresolved_files_)
        set(${vcpkg_resolve_deploy_object_dependencies_UNRESOLVED_DEPENDENCIES_RESULT} "${unresolved_files_}" PARENT_SCOPE)
    endif()

endfunction()

function(z_vcpkg_copy_tool_dependencies_search tool_dir path_to_search)
    if(DEFINED Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT)
        set(count ${Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT})
    else()
        set(count 0)
    endif()
    file(GLOB tools "${tool_dir}/*.exe" "${tool_dir}/*.dll" "${tool_dir}/*.pyd")
    list(LENGTH tools tools_count_)
    set(Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT ${tools_count_} CACHE INTERNAL "")
    vcpkg_resolve_deploy_object_dependencies(
        TARGET_OBJECT_PATHS "${tools}"
        ADDITIONAL_SEARCH_PATHS "${path_to_search}"
        DEPENDENCY_LIST_RESULT deployed_dependencies_
    )
endfunction()

function(vcpkg_copy_tool_dependencies tool_dir)
    message(STATUS "vcpkg_copy_tool_dependencies: Copying tool dependencies for ${tool_dir}")
    if(ARGC GREATER 1)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${ARGN}")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS)
        cmake_path(RELATIVE_PATH tool_dir
            BASE_DIRECTORY "${CURRENT_PACKAGES_DIR}"
            OUTPUT_VARIABLE relative_tool_dir
        )
        if(relative_tool_dir MATCHES "^debug/|/debug/")
            set(additional_search_paths_ "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_INSTALLED_DIR}/debug/bin")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${additional_search_paths_}")
        else()
            set(additional_search_paths_ "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_INSTALLED_DIR}/bin")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${additional_search_paths_}")
        endif()
    endif()
endfunction()

# region Special Handlers

# Given a target, check if it is a Magnum module. Return TRUE or FALSE.
#
# param TARGET_OBJECT_PATH - string, required. path to the target object
# param IS_DETECTED_RESULT - boolean, required, output variable. TRUE if the target is a Magnum module, FALSE otherwise
function(detect_dependency_magnum)

    set(one_value_args_ TARGET_OBJECT_PATH IS_DETECTED_RESULT)
    cmake_parse_arguments(detect_dependency_magnum "" "${one_value_args_}" "" ${ARGN})

    if (NOT detect_dependency_magnum_TARGET_OBJECT_PATH)
        message(FATAL_ERROR "detect_dependency_magnum: Missing required argument 'TARGET_OBJECT_PATH'")
    endif()
    if (NOT detect_dependency_magnum_IS_DETECTED_RESULT)
        message(FATAL_ERROR "detect_dependency_magnum: Missing required argument 'IS_DETECTED_RESULT'")
    endif()

    get_filename_component(target_name_ "${detect_dependency_magnum_TARGET_OBJECT_PATH}" NAME)

    if (target_name_ MATCHES "MagnumAudio(-d)?\\.dll"
        OR target_name_ MATCHES "MagnumText(-d)?\\.dll"
        OR target_name_ MATCHES "MagnumTrade(-d)?\\.dll"
        OR target_name_ MATCHES "MagnumShaderTools(-d)?\\.dll"
    )
        set(${detect_dependency_magnum_IS_DETECTED_RESULT} TRUE PARENT_SCOPE)
    else()
        set(${detect_dependency_magnum_IS_DETECTED_RESULT} FALSE PARENT_SCOPE)
    endif()

endfunction()

# Magnum's plugin deployment strategy is that each Magnum module has a hardcoded
# set of plugin directories. Each of these directories is deployed in
# full if that Module is referenced.
#
# param TARGET_OBJECT_PATH - string, required. path to the target object
# param MAGNUM_PLUGINS_DIR - string, required. path to the Magnum plugins directory
# param DEPLOYED_FILES_RESULT - list<string>, required, output variable. list of deployed files
# param DEPENDENCIES_TO_RESOLVE_RESULT - list<string>, required, output variable. list of dependencies that need further resolution
function(deploy_dependencies_magnum)

    set(one_value_args_ TARGET_OBJECT_PATH MAGNUM_PLUGINS_DIR DEPLOYED_FILES_RESULT DEPENDENCIES_TO_RESOLVE_RESULT)
    cmake_parse_arguments(deploy_plugins_magnum "" "${one_value_args_}" "" ${ARGN})

    if (NOT deploy_plugins_magnum_TARGET_OBJECT_PATH)
        message(FATAL_ERROR "deploy_plugins_magnum: Missing required argument 'TARGET_OBJECT_PATH'")
    endif()
    if (NOT deploy_plugins_magnum_MAGNUM_PLUGINS_DIR)
        message(FATAL_ERROR "deploy_plugins_magnum: Missing required argument 'MAGNUM_PLUGINS_DIR'")
    endif()
    if (NOT deploy_plugins_magnum_DEPLOYED_FILES_RESULT)
        message(FATAL_ERROR "deploy_plugins_magnum: Missing required argument 'DEPLOYED_FILES_RESULT'")
    endif()
    if (NOT deploy_plugins_magnum_DEPENDENCIES_TO_RESOLVE_RESULT)
        message(FATAL_ERROR "deploy_plugins_magnum: Missing required argument 'DEPENDENCIES_TO_RESOLVE_RESULT'")
    endif()

    get_filename_component(target_name_ "${deploy_plugins_magnum_TARGET_OBJECT_PATH}" NAME) # targetBinaryName
    get_filename_component(target_dir_ "${deploy_plugins_magnum_TARGET_OBJECT_PATH}" DIRECTORY) # targetBinaryDir

    cmake_path(GET deploy_plugins_magnum_MAGNUM_PLUGINS_DIR PARENT_PATH plugins_base_dir_) #baseDir
    cmake_path(APPEND plugins_base_dir_ "bin" OUTPUT_VARIABLE plugins_bin_dir_) #binDir
    get_filename_component(plugins_base_dir_name_ "${plugins_base_dir_}" NAME) #baseDirName

    message(STATUS "Deploying magnum plugins")
    set(all_copied_files_list_ "")

    # We detect Magnum modules in use via the DLLs that contain their plugin interfaces
    if (target_name_ MATCHES "MagnumAudio(-d)?\\.dll")
        cmake_path(APPEND deploy_plugins_magnum_MAGNUM_PLUGINS_DIR "audioimporters" OUTPUT_VARIABLE from_directory_)
        cmake_path(APPEND target_dir_ "${plugins_base_dir_name_}" "audioimporters" OUTPUT_VARIABLE to_directory_)
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${from_directory_}"
            TO_DIRECTORY "${to_directory_}"
            EXTENSIONS DLL CONF PDB
            COPIED_FILES_RESULT deployed_files_list_
        )
        list(APPEND all_copied_files_list_ "${deployed_files_list_}")
    endif()

    if (target_name_ MATCHES "MagnumText(-d)?\\.dll")
        cmake_path(APPEND deploy_plugins_magnum_MAGNUM_PLUGINS_DIR "fonts" OUTPUT_VARIABLE from_directory_)
        cmake_path(APPEND target_dir_ "${plugins_base_dir_name_}" "fonts" OUTPUT_VARIABLE to_directory_)
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${from_directory_}"
            TO_DIRECTORY "${to_directory_}"
            EXTENSIONS DLL CONF PDB
            COPIED_FILES_RESULT deployed_files_list_
        )
        list(APPEND all_copied_files_list_ "${deployed_files_list_}")

        cmake_path(APPEND deploy_plugins_magnum_MAGNUM_PLUGINS_DIR "fontconverters" OUTPUT_VARIABLE from_directory_)
        cmake_path(APPEND target_dir_ "${plugins_base_dir_name_}" "fontconverters" OUTPUT_VARIABLE to_directory_)
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${from_directory_}"
            TO_DIRECTORY "${to_directory_}"
            EXTENSIONS DLL CONF PDB
            COPIED_FILES_RESULT deployed_files_list_
        )
        list(APPEND all_copied_files_list_ "${deployed_files_list_}")
    endif()

    if (target_name_ MATCHES "MagnumTrade(-d)?\\.dll")
        cmake_path(APPEND deploy_plugins_magnum_MAGNUM_PLUGINS_DIR "importers" OUTPUT_VARIABLE from_directory_)
        cmake_path(APPEND target_dir_ "${plugins_base_dir_name_}" "importers" OUTPUT_VARIABLE to_directory_)
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${from_directory_}"
            TO_DIRECTORY "${to_directory_}"
            EXTENSIONS DLL CONF PDB
            COPIED_FILES_RESULT deployed_files_list_
        )
        list(APPEND all_copied_files_list_ "${deployed_files_list_}")

        cmake_path(APPEND deploy_plugins_magnum_MAGNUM_PLUGINS_DIR "imageconverters" OUTPUT_VARIABLE from_directory_)
        cmake_path(APPEND target_dir_ "${plugins_base_dir_name_}" "imageconverters" OUTPUT_VARIABLE to_directory_)
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${from_directory_}"
            TO_DIRECTORY "${to_directory_}"
            EXTENSIONS DLL CONF PDB
            COPIED_FILES_RESULT deployed_files_list_
        )
        list(APPEND all_copied_files_list_ "${deployed_files_list_}")

        cmake_path(APPEND deploy_plugins_magnum_MAGNUM_PLUGINS_DIR "sceneconverters" OUTPUT_VARIABLE from_directory_)
        cmake_path(APPEND target_dir_ "${plugins_base_dir_name_}" "sceneconverters" OUTPUT_VARIABLE to_directory_)
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${from_directory_}"
            TO_DIRECTORY "${to_directory_}"
            EXTENSIONS DLL CONF PDB
            COPIED_FILES_RESULT deployed_files_list_
        )
        list(APPEND all_copied_files_list_ "${deployed_files_list_}")
    endif()

    if (target_name_ MATCHES "MagnumShaderTools(-d)?\\.dll")
        cmake_path(APPEND deploy_plugins_magnum_MAGNUM_PLUGINS_DIR "shaderconverters" OUTPUT_VARIABLE from_directory_)
        cmake_path(APPEND target_dir_ "${plugins_base_dir_name_}" "shaderconverters" OUTPUT_VARIABLE to_directory_)
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${from_directory_}"
            TO_DIRECTORY "${to_directory_}"
            EXTENSIONS DLL CONF PDB
            COPIED_FILES_RESULT deployed_files_list_
        )
        list(APPEND all_copied_files_list_ "${deployed_files_list_}")
    endif()

    set(${deploy_plugins_magnum_DEPLOYED_FILES_RESULT} "${all_copied_files_list_}" PARENT_SCOPE)
    set(${deploy_plugins_magnum_DEPENDENCIES_TO_RESOLVE_RESULT} "${all_copied_files_list_}" PARENT_SCOPE)

endfunction()

# Given a target, check if it is an Azure Kinect Sensor SDK module. Return TRUE or FALSE.
#
# param TARGET_OBJECT_PATH - string, required. path to the target object
# param IS_DETECTED_RESULT - boolean, required, output variable. TRUE if the target is an Azure Kinect Sensor SDK module, FALSE otherwise
function(detect_dependency_azure_kinect_sensor_sdk)

    set(one_value_args_ TARGET_OBJECT_PATH IS_DETECTED_RESULT)
    cmake_parse_arguments(detect_azure_kinect_sensor_sdk "" "${one_value_args_}" "" ${ARGN})

    if (NOT detect_azure_kinect_sensor_sdk_TARGET_OBJECT_PATH)
        message(FATAL_ERROR "detect_azure_kinect_sensor_sdk: Missing required argument 'TARGET_OBJECT_PATH'")
    endif()
    if (NOT detect_azure_kinect_sensor_sdk_IS_DETECTED_RESULT)
        message(FATAL_ERROR "detect_azure_kinect_sensor_sdk: Missing required argument 'IS_DETECTED_RESULT'")
    endif()

    get_filename_component(target_name_ "${detect_azure_kinect_sensor_sdk_TARGET_OBJECT_PATH}" NAME)

    if (target_name_ STREQUAL "k4a.dll")
        set(${detect_azure_kinect_sensor_sdk_IS_DETECTED_RESULT} TRUE PARENT_SCOPE)
    else()
        set(${detect_azure_kinect_sensor_sdk_IS_DETECTED_RESULT} FALSE PARENT_SCOPE)
    endif()

endfunction()

# Special handling for Azure Kinect Sensor SDK
#
# param TARGET_OBJECT_PATH - string, required. path to the target object
# param KINECT_INSTALLED_DIR - string, required. path to the Azure Kinect Sensor SDK installation directory
# param DEPLOYED_FILES_RESULT - list<string>, required, output variable. list of deployed files
# param DEPENDENCIES_TO_RESOLVE_RESULT - list<string>, required, output variable. list of dependencies that need further resolution
function(deploy_dependencies_azure_kinect_sensor_sdk)

    set(one_value_args_ TARGET_OBJECT_PATH KINECT_INSTALLED_DIR DEPLOYED_FILES_RESULT DEPENDENCIES_TO_RESOLVE_RESULT)
    cmake_parse_arguments(deploy_dependencies_azure_kinect_sensor_sdk "" "${one_value_args_}" "" ${ARGN})

    if (NOT deploy_dependencies_azure_kinect_sensor_sdk_TARGET_OBJECT_PATH)
        message(FATAL_ERROR "deploy_dependencies_azure_kinect_sensor_sdk: Missing required argument 'TARGET_OBJECT_PATH'")
    endif()
    if (NOT deploy_dependencies_azure_kinect_sensor_sdk_KINECT_INSTALLED_DIR)
        message(FATAL_ERROR "deploy_dependencies_azure_kinect_sensor_sdk: Missing required argument 'KINECT_INSTALLED_DIR'")
    endif()
    if (NOT deploy_dependencies_azure_kinect_sensor_sdk_DEPLOYED_FILES_RESULT)
        message(FATAL_ERROR "deploy_dependencies_azure_kinect_sensor_sdk: Missing required argument 'DEPLOYED_FILES_RESULT'")
    endif()
    if (NOT deploy_dependencies_azure_kinect_sensor_sdk_DEPENDENCIES_TO_RESOLVE_RESULT)
        message(FATAL_ERROR "deploy_dependencies_azure_kinect_sensor_sdk: Missing required argument 'DEPENDENCIES_TO_RESOLVE_RESULT'")
    endif()

    message(STATUS "deploy_dependencies_azure_kinect_sensor_sdk: Deploying Azure Kinect Sensor SDK Initialization")
    get_filename_component(target_dir_ "${deploy_dependencies_azure_kinect_sensor_sdk_TARGET_OBJECT_PATH}" DIRECTORY)

    cmake_path(APPEND deploy_dependencies_azure_kinect_sensor_sdk_KINECT_INSTALLED_DIR "tools" "azure-kinect-sensor-sdk"
            OUTPUT_VARIABLE kinect_dependency_location_
    )

    set(deployed_files_list_ "")
    if (EXISTS "${kinect_dependency_location_}")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${kinect_dependency_location_}"
            TO_DIRECTORY "${target_dir_}"
            FILE_PATTERNS "depthengine_2_0.dll"
            COPIED_FILES_RESULT deployed_files_list_
        )
    else()
        message(FATAL_ERROR "deploy_dependencies_azure_kinect_sensor_sdk: Could not find Azure Kinect Sensor SDK dependency at ${kinect_dependency_location_}")
    endif()

    set(${deploy_dependencies_azure_kinect_sensor_sdk_DEPLOYED_FILES_RESULT} "${deployed_files_list_}" PARENT_SCOPE)
    set(${deploy_dependencies_azure_kinect_sensor_sdk_DEPENDENCIES_TO_RESOLVE_RESULT} "" PARENT_SCOPE)

endfunction()

# Given a target, check if it is a Qt module that requires special handling. Return TRUE or FALSE.
#
# param TARGET_OBJECT_PATH - string, required. path to the target object
# param IS_DETECTED_RESULT - boolean, required, output variable. TRUE if the target is a Qt module, FALSE otherwise
function(detect_dependency_qt_module)

    set(one_value_args_ TARGET_OBJECT_PATH IS_DETECTED_RESULT)
    cmake_parse_arguments(detect_dependency_qt_module "" "${one_value_args_}" "" ${ARGN})

    if (NOT detect_dependency_qt_module_TARGET_OBJECT_PATH)
        message(FATAL_ERROR "detect_dependency_qt_module: Missing required argument 'TARGET_OBJECT_PATH'")
    endif()
    if (NOT detect_dependency_qt_module_IS_DETECTED_RESULT)
        message(FATAL_ERROR "detect_dependency_qt_module: Missing required argument 'IS_DETECTED_RESULT'")
    endif()

    get_filename_component(target_name_ "${detect_dependency_qt_module_TARGET_OBJECT_PATH}" NAME)

    if (target_name_ MATCHES "Qt5.*\\.dll")
        set(${detect_dependency_qt_module_IS_DETECTED_RESULT} TRUE PARENT_SCOPE)
    else()
        set(${detect_dependency_qt_module_IS_DETECTED_RESULT} FALSE PARENT_SCOPE)
    endif()

endfunction()

# Special handling for Qt modules
#
# param TARGET_OBJECT_PATH - string, required. path to the target object
# param QT_PLUGINS_DIR - string, required. path to the Qt plugins directory
# param DEPLOYED_FILES_RESULT - list<string>, required, output variable. list of deployed files
# param DEPENDENCIES_TO_RESOLVE_RESULT - list<string>, required, output variable. list of dependencies that need further resolution
function(deploy_dependencies_qt_module)

    set(one_value_args_ TARGET_OBJECT_PATH QT_PLUGINS_DIR DEPLOYED_FILES_RESULT DEPENDENCIES_TO_RESOLVE_RESULT)
    cmake_parse_arguments(deploy_dependencies_qt_module "" "${one_value_args_}" "" ${ARGN})

    if (NOT deploy_dependencies_qt_module_TARGET_OBJECT_PATH)
        message(FATAL_ERROR "deploy_dependencies_qt_module: Missing required argument 'TARGET_OBJECT_PATH'")
    endif()
    if (NOT deploy_dependencies_qt_module_QT_PLUGINS_DIR)
        message(FATAL_ERROR "deploy_dependencies_qt_module: Missing required argument 'QT_PLUGINS_DIR'")
    endif()
    if (NOT deploy_dependencies_qt_module_DEPLOYED_FILES_RESULT)
        message(FATAL_ERROR "deploy_dependencies_qt_module: Missing required argument 'DEPLOYED_FILES_RESULT'")
    endif()
    if (NOT deploy_dependencies_qt_module_DEPENDENCIES_TO_RESOLVE_RESULT)
        message(FATAL_ERROR "deploy_dependencies_qt_module: Missing required argument 'DEPENDENCIES_TO_RESOLVE_RESULT'")
    endif()

    set(all_copied_files_ "")
    set(still_to_resolve_files_ "")

    cmake_path(GET deploy_dependencies_qt_module_QT_PLUGINS_DIR PARENT_PATH qt_plugins_base_dir_)
    cmake_path(APPEND qt_plugins_base_dir_ "bin" OUTPUT_VARIABLE qt_plugins_bin_dir_)
    get_filename_component(target_name_ "${deploy_dependencies_qt_module_TARGET_OBJECT_PATH}" NAME)
    get_filename_component(target_dir_ "${deploy_dependencies_qt_module_TARGET_OBJECT_PATH}" DIRECTORY)
    cmake_path(APPEND target_dir_ "plugins" OUTPUT_VARIABLE target_plugins_dir_)

    message(STATUS "deploy_dependencies_qt_module: Deploying Qt5 Module: ${target_name_}")

    # Ensure that the qt.conf file exists, if not, create it
    if (target_name_ MATCHES "Qt5Cored?.dll")
        cmake_path(APPEND target_dir_ "qt.conf" OUTPUT_VARIABLE qt_conf_path_)
        if (NOT EXISTS "${qt_conf_path_}")
            message(STATUS "deploy_dependencies_qt_module: qt.conf file does not exist at ${qt_conf_path_}. Creating it.")
            file(WRITE "${qt_conf_path_}" "[Paths]")
        endif()
    endif()

    if (target_name_ MATCHES "Qt5Guid?.dll")

        message(STATUS "deploy_dependencies_qt_module: Deploying platforms")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/platforms"
            TO_DIRECTORY "${target_plugins_dir_}/platforms"
            COPIED_FILES_RESULT deployed_files_
            FILE_PATTERNS "qwindows*.dll"
        )
        list(APPEND all_copied_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/accessible"
            TO_DIRECTORY "${target_plugins_dir_}/accessible"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/imageformats"
            TO_DIRECTORY "${target_plugins_dir_}/imageformats"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/iconengines"
            TO_DIRECTORY "${target_plugins_dir_}/iconengines"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/platforminputcontexts"
            TO_DIRECTORY "${target_plugins_dir_}/platforminputcontexts"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/styles"
            TO_DIRECTORY "${target_plugins_dir_}/styles"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

    endif() # Qt5Guid?.dll

    if (target_name_ MATCHES "Qt5Networkd?.dll")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/bearer"
            TO_DIRECTORY "${target_plugins_dir_}/bearer"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${qt_plugins_bin_dir_}"
            TO_DIRECTORY "${target_dir_}"
            FILE_PATTERNS "libcrypto-*-x64.dll" "libssl-*-x64.dll" "libcrypto-*.dll" "libssl-*.dll"
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")

    endif() # Qt5Networkd?.dll

    if (target_name_ MATCHES "Qt5Sqld?.dll")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/sqldrivers"
            TO_DIRECTORY "${target_plugins_dir_}/sqldrivers"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")
    endif() # Qt5Sqld?.dll

    if (target_name_ MATCHES "Qt5Multimediad?.dll")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/audio"
            TO_DIRECTORY "${target_plugins_dir_}/audio"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/mediaservice"
            TO_DIRECTORY "${target_plugins_dir_}/mediaservice"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/playlistformats"
            TO_DIRECTORY "${target_plugins_dir_}/playlistformats"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

    endif() # Qt5Multimediad?.dll

    if (target_name_ MATCHES "Qt5PrintSupportd?.dll")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/printsupport"
            TO_DIRECTORY "${target_plugins_dir_}/printsupport"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

    endif() # Qt5PrintSupportd?.dll

    if (target_name_ MATCHES "Qt5Qmld?.dll")

        # Ensure that /qml directory exists and its populated with bin/qml files
        if (NOT EXISTS "${target_dir_}/qml")
            message(STATUS "deploy_dependencies_qt_module: Creating /qml directory at ${target_dir_}/qml")
            file(MAKE_DIRECTORY "${target_dir_}/qml")
            # Try to find the files to copy from
            cmake_path(APPEND qt_plugins_base_dir_ "qml" OUTPUT_VARIABLE qml_source_dir_option_0_)
            cmake_path(APPEND qt_plugins_base_dir_ ".." "qml" OUTPUT_VARIABLE qml_source_dir_option_1_)
            if (EXISTS "${qml_source_dir_option_0_}")
                message(STATUS "deploy_dependencies_qt_module: Found qml source directory at ${qml_source_dir_option_0_}. Copying directory to ${target_dir_}/qml")
                file(COPY "${qml_source_dir_option_0_}" DESTINATION "${target_dir_}/qml")
            elseif (EXISTS "${qml_source_dir_option_1_}")
                message(STATUS "deploy_dependencies_qt_module: Found qml source directory at ${qml_source_dir_option_1_}. Copying directory to ${target_dir_}/qml")
                file(COPY "${qml_source_dir_option_1_}" DESTINATION "${target_dir_}/qml")
            else()
                message(FATAL_ERROR "deploy_dependencies_qt_module: Could not find qml source directory at ${qml_source_dir_option_0_} nor ${qml_source_dir_option_1_}.")
            endif()
        endif()

        set(dlls_to_copy_
            "Qt5Quick.dll"
            "Qt5Quickd.dll"
            "Qt5QmlModels.dll"
            "Qt5QmlModelsd.dll"
            "Qt5QuickControls2.dll"
            "Qt5QuickControls2d.dll"
            "Qt5QuickShapes.dll"
            "Qt5QuickShapesd.dll"
            "Qt5QuickTemplates2.dll"
            "Qt5QuickTemplates2d.dll"
            "Qt5QmlWorkerScript.dll"
            "Qt5QmlWorkerScriptd.dll"
            "Qt5QuickParticles.dll"
            "Qt5QuickParticlesd.dll"
            "Qt5QuickWidgets.dll"
            "Qt5QuickWidgetsd.dll"
        )
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${qt_plugins_bin_dir_}"
            TO_DIRECTORY "${target_dir_}"
            FILE_PATTERNS "${dlls_to_copy_}"
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/scenegraph"
            TO_DIRECTORY "${target_plugins_dir_}/scenegraph"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )

        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/qmltooling"
            TO_DIRECTORY "${target_plugins_dir_}/qmltooling"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

    endif() # Qt5Qmld?.dll

    if (target_name_ MATCHES "Qt5Quickd?.dll")

        set(dlls_to_copy_
            "Qt5QuickControls2.dll"
            "Qt5QuickControls2d.dll"
            "Qt5QuickShapes.dll"
            "Qt5QuickShapesd.dll"
            "Qt5QuickTemplates2.dll"
            "Qt5QuickTemplates2d.dll"
            "Qt5QmlWorkerScript.dll"
            "Qt5QmlWorkerScriptd.dll"
            "Qt5QuickParticles.dll"
            "Qt5QuickParticlesd.dll"
            "Qt5QuickWidgets.dll"
            "Qt5QuickWidgetsd.dll"
        )
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${qt_plugins_bin_dir_}"
            TO_DIRECTORY "${target_dir_}"
            FILE_PATTERNS "${dlls_to_copy_}"
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/scenegraph"
            TO_DIRECTORY "${target_plugins_dir_}/scenegraph"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/qmltooling"
            TO_DIRECTORY "${target_plugins_dir_}/qmltooling"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

    endif() # Qt5Quickd?.dll

    if (target_name_ MATCHES "Qt5Declarative*.dll")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/qml1tooling"
            TO_DIRECTORY "${target_plugins_dir_}/qml1tooling"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")
    endif() # Qt5Declarative*.dll

    if (target_name_ MATCHES "Qt5Positioning*.dll")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/position"
            TO_DIRECTORY "${target_plugins_dir_}/position"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")
    endif() # Qt5Positioning*.dll

    if (target_name_ MATCHES "Qt5Location*.dll")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/geoservices"
            TO_DIRECTORY "${target_plugins_dir_}/geoservices"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")
    endif() # Qt5Location*.dll

    if (target_name_ MATCHES "Qt5Sensors*.dll")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/sensors"
            TO_DIRECTORY "${target_plugins_dir_}/sensors"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/sensorgestures"
            TO_DIRECTORY "${target_plugins_dir_}/sensorgestures"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")

    endif() # Qt5Sensors*.dll

    if (target_name_ MATCHES "Qt5WebEngineCore*.dll")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/qtwebengine"
            TO_DIRECTORY "${target_plugins_dir_}/qtwebengine"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")
    endif() # Qt5WebEngineCore*.dll

    if (target_name_ MATCHES "Qt53DRenderer*.dll")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/sceneparsers"
            TO_DIRECTORY "${target_plugins_dir_}/sceneparsers"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")
    endif() # Qt53DRenderer*.dll

    if (target_name_ MATCHES "Qt5TextToSpeech*.dll")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/texttospeech"
            TO_DIRECTORY "${target_plugins_dir_}/texttospeech"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")
    endif() # Qt5TextToSpeech*.dll

    if (target_name_ MATCHES "Qt5SerialBus*.dll")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${deploy_dependencies_qt_module_QT_PLUGINS_DIR}/canbus"
            TO_DIRECTORY "${target_plugins_dir_}/canbus"
            EXTENSIONS DLL
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
        list(APPEND still_to_resolve_files_ "${deployed_files_}")
    endif() # Qt5SerialBus*.dll

    list(REMOVE_DUPLICATES all_copied_files_)
    set(${deploy_dependencies_qt_module_DEPLOYED_FILES_RESULT} "${all_copied_files_}" PARENT_SCOPE)
    set(${deploy_dependencies_qt_module_DEPENDENCIES_TO_RESOLVE_RESULT} "${still_to_resolve_files_}" PARENT_SCOPE)

endfunction()

# Given a target, check if it is an OpenNI2 module. Return TRUE or FALSE.
#
# param TARGET_OBJECT_PATH - string, required. path to the target object
# param IS_DETECTED_RESULT - boolean, required, output variable. TRUE if the target is an OpenNI2 module, FALSE otherwise
function(detect_dependency_OpenNI2)

    set(one_value_args_ TARGET_OBJECT_PATH IS_DETECTED_RESULT)
    cmake_parse_arguments(detect_dependency_OpenNI2 "" "${one_value_args_}" "" ${ARGN})

    if (NOT detect_dependency_OpenNI2_TARGET_OBJECT_PATH)
        message(FATAL_ERROR "detect_dependency_OpenNI2: Missing required argument 'TARGET_OBJECT_PATH'")
    endif()
    if (NOT detect_dependency_OpenNI2_IS_DETECTED_RESULT)
        message(FATAL_ERROR "detect_dependency_OpenNI2: Missing required argument 'IS_DETECTED_RESULT'")
    endif()

    get_filename_component(target_name_ "${detect_dependency_OpenNI2_TARGET_OBJECT_PATH}" NAME)

    if (target_name_ MATCHES "OpenNI2.dll")
        set(${detect_dependency_OpenNI2_IS_DETECTED_RESULT} TRUE PARENT_SCOPE)
    else()
        set(${detect_dependency_OpenNI2_IS_DETECTED_RESULT} FALSE PARENT_SCOPE)
    endif()

endfunction()

# Special handling for OpenNI2 modules
#
# param TARGET_OBJECT_PATH - string, required. path to the target object
# param OPEN_NI2_INSTALLED_DIR - string, required. path to the OpenNI2 installation directory
# param DEPLOYED_FILES_RESULT - list<string>, required, output variable. list of deployed files
# param DEPENDENCIES_TO_RESOLVE_RESULT - list<string>, required, output variable. list of dependencies that need further resolution
function(deploy_dependencies_OpenNI2)

    set(one_value_args_ TARGET_OBJECT_PATH OPEN_NI2_INSTALLED_DIR DEPLOYED_FILES_RESULT DEPENDENCIES_TO_RESOLVE_RESULT)
    cmake_parse_arguments(deploy_dependencies_OpenNI2 "" "${one_value_args_}" "" ${ARGN})

    if (NOT deploy_dependencies_OpenNI2_TARGET_OBJECT_PATH)
        message(FATAL_ERROR "deploy_dependencies_OpenNI2: Missing required argument 'TARGET_OBJECT_PATH'")
    endif()
    if (NOT deploy_dependencies_OpenNI2_OPEN_NI2_INSTALLED_DIR)
        message(FATAL_ERROR "deploy_dependencies_OpenNI2: Missing required argument 'OPEN_NI2_INSTALLED_DIR'")
    endif()
    if (NOT deploy_dependencies_OpenNI2_DEPLOYED_FILES_RESULT)
        message(FATAL_ERROR "deploy_dependencies_OpenNI2: Missing required argument 'DEPLOYED_FILES_RESULT'")
    endif()

    set(all_copied_files_ "")

    cmake_path(APPEND deploy_dependencies_OpenNI2_OPEN_NI2_INSTALLED_DIR "bin" "OpenNI2" OUTPUT_VARIABLE openni2_bin_base_dir_)
    cmake_path(APPEND openni2_bin_base_dir_ "OpenNI.ini" OUTPUT_VARIABLE ini_location_)

    get_filename_component(target_dir_ "${deploy_dependencies_OpenNI2_TARGET_OBJECT_PATH}" DIRECTORY)

    if (EXISTS "${ini_location_}")
        message(STATUS "deploy_dependencies_OpenNI2: Deploying OpenNI2 Initialization")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${openni2_bin_base_dir_}"
            TO_DIRECTORY "${target_dir_}"
            FILE_PATTERNS "OpenNI.ini"
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
    endif()

    cmake_path(APPEND openni2_bin_base_dir_ "Drivers" OUTPUT_VARIABLE openni2_drivers_dir_)
    cmake_path(APPEND target_dir_ "OpenNI2" "Drivers" OUTPUT_VARIABLE target_drivers_dir_)

    if (EXISTS openni2_drivers_dir_)
        message(STATUS "deploy_dependencies_OpenNI2: Deploying OpenNI2 Drivers")
        vcpkg_copy_from_directory(
            FROM_DIRECTORY "${openni2_drivers_dir_}"
            TO_DIRECTORY "${target_drivers_dir_}"
            EXTENSIONS DLL INI
            COPIED_FILES_RESULT deployed_files_
        )
        list(APPEND all_copied_files_ "${deployed_files_}")
    endif()

    list(REMOVE_DUPLICATES all_copied_files_)
    set(${deploy_dependencies_OpenNI2_DEPLOYED_FILES_RESULT} "${all_copied_files_}" PARENT_SCOPE)
    if (deploy_dependencies_OpenNI2_DEPENDENCIES_TO_RESOLVE_RESULT) # optional since always returns an empty list
        set(${deploy_dependencies_OpenNI2_DEPENDENCIES_TO_RESOLVE_RESULT} "" PARENT_SCOPE)
    endif()

endfunction()

# endregion Special Handlers