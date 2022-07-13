cmake_minimum_required(VERSION 3.15)

function(z_vcpkg_copy_tool_dependencies_search_win tool_dir path_to_search)
    if(DEFINED Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT)
        set(count ${Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT})
    else()
        set(count 0)
    endif()
    file(GLOB tools "${tool_dir}/*.exe" "${tool_dir}/*.dll" "${tool_dir}/*.pyd")
    foreach(tool IN LISTS tools)
        vcpkg_execute_required_process(
            COMMAND "${Z_VCPKG_POWERSHELL_CORE}" -noprofile -executionpolicy Bypass -nologo
                -file "${SCRIPTS}/buildsystems/msbuild/applocal.ps1"
                -targetBinary "${tool}"
                -installedDir "${path_to_search}"
                -verbose
            WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
            LOGNAME copy-tool-dependencies-${count}
        )
        math(EXPR count "${count} + 1")
    endforeach()
    set(Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT ${count} CACHE INTERNAL "")
endfunction()

function(z_vcpkg_copy_tool_dependencies_search_linux tool_dir path_to_search_list)
    file(GLOB tools "${tool_dir}/*")
    foreach(tool IN LISTS tools)
        # List all dependencies.
        execute_process(
            COMMAND ldd ${tool}
            RESULT_VARIABLE ldd_command_result
            OUTPUT_VARIABLE ldd_command_output
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            ERROR_QUIET
        )
        # This one is not a dynamic executable, skip~
        if(NOT ldd_command_result EQUAL 0)
            continue()
        endif()
        # Find out all dependency mappings
        string(REGEX MATCHALL "[^ \t\r\n]+ => [^\r\n]+" dependencies_mapping_list "${ldd_command_output}")
        # Handle one by one
        foreach(dependency_mapping IN LISTS dependencies_mapping_list)
            if(dependency_mapping MATCHES "([^ \t\r\n]+) => ([^ \t\r\n]+)")
                set(dependency_name ${CMAKE_MATCH_1})
                set(dependency_path ${CMAKE_MATCH_2})
                # Skip system dependencies
                if(dependency_path MATCHES "^/lib|^/usr|^/local")
                    continue()
                endif()
                # Search target dependency
                foreach(path_to_search IN LISTS path_to_search_list)
                    set(dependency_path ${path_to_search}/${dependency_name})
                    if(EXISTS ${dependency_path})
                        break()
                    endif()
                endforeach()
                # Not found
                if(NOT EXISTS ${dependency_path})
                    message(FATAL_ERROR "Dependency ${dependency_name} of the following tool is not found. \n   ${tool}\n")
                endif()
                # Copy the dependency
                if(NOT EXISTS ${tool_dir}/${dependency_name})
                    file(COPY ${dependency_path} DESTINATION ${tool_dir} FOLLOW_SYMLINK_CHAIN)
                    message(STATUS "Copy dependency ${dependency_name} into ${tool_dir}")
                endif()
            endif()
        endforeach()
    endforeach()
endfunction()

function(vcpkg_copy_tool_dependencies tool_dir)
    if(ARGC GREATER 1)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${ARGN}")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS)
        find_program(Z_VCPKG_POWERSHELL_CORE pwsh)
        if (NOT Z_VCPKG_POWERSHELL_CORE)
            message(FATAL_ERROR "Could not find PowerShell Core; please open an issue to report this.")
        endif()
        cmake_path(RELATIVE_PATH tool_dir
            BASE_DIRECTORY "${CURRENT_PACKAGES_DIR}"
            OUTPUT_VARIABLE relative_tool_dir
        )
        if(relative_tool_dir MATCHES "/debug/")
            z_vcpkg_copy_tool_dependencies_search_win("${tool_dir}" "${CURRENT_PACKAGES_DIR}/debug/bin")
            z_vcpkg_copy_tool_dependencies_search_win("${tool_dir}" "${CURRENT_INSTALLED_DIR}/debug/bin")
        else()
            z_vcpkg_copy_tool_dependencies_search_win("${tool_dir}" "${CURRENT_PACKAGES_DIR}/bin")
            z_vcpkg_copy_tool_dependencies_search_win("${tool_dir}" "${CURRENT_INSTALLED_DIR}/bin")
        endif()
    elseif(VCPKG_TARGET_IS_LINUX)
        if(relative_tool_dir MATCHES "/debug/")
            list(APPEND path_to_search_list
                ${CURRENT_PACKAGES_DIR}/debug/lib
                ${CURRENT_INSTALLED_DIR}/debug/lib
            )
            z_vcpkg_copy_tool_dependencies_search_linux("${tool_dir}" "${path_to_search_list}")
        else()
            list(APPEND path_to_search_list
                ${CURRENT_PACKAGES_DIR}/lib
                ${CURRENT_INSTALLED_DIR}/lib
            )
            z_vcpkg_copy_tool_dependencies_search_linux("${tool_dir}" "${path_to_search_list}")
        endif()
    endif()
endfunction()
