function(z_vcpkg_copy_tool_dependencies_search tool_dir path_to_search)
    if(DEFINED Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT)
        set(count ${Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT})
    else()
        set(count 0)
    endif()
    file(GLOB tools "${tool_dir}/*.exe" "${tool_dir}/*.dll" "${tool_dir}/*.pyd")
    if (CMAKE_MAJOR_VERSION VERSION_GREATER_EQUAL 3 AND CMAKE_MINOR_VERSION VERSION_GREATER_EQUAL 16)
        foreach(tool IN LISTS tools)
            file(GET_RUNTIME_DEPENDENCIES
                RESOLVED_DEPENDENCIES_VAR RESOLVED_DEPS
                UNRESOLVED_DEPENDENCIES_VAR UNRESOLVED_DEPS
                CONFLICTING_DEPENDENCIES_PREFIX CONFLICT_DEPS
                LIBRARIES "${tool}"
                DIRECTORIES "${CURRENT_INSTALLED_DIR}/bin" "${CURRENT_PACKAGES_DIR}/bin"
            )
            debug_message("Found dependencies: ${RESOLVED_DEPS};${CONFLICT_DEPS}\nNot found: ${UNRESOLVED_DEPS}")
            foreach(dependency IN LISTS RESOLVED_DEPS CONFLICT_DEPS)
                # The native path will break MATCHES
                file(TO_CMAKE_PATH "${dependency}" dependency)
                if ("${dependency}" MATCHES "^${CURRENT_PACKAGES_DIR}" OR "${dependency}" MATCHES "^${CURRENT_INSTALLED_DIR}")
                    debug_message("COPY dependency ${dependency}...")
                    file(COPY "${dependency}" DESTINATION "${tool_dir}")
                endif()
            endforeach()
            math(EXPR count "${count} + 1")
        endforeach()
    else()
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
    endif()
    set(Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT ${count} CACHE INTERNAL "")
endfunction()

function(vcpkg_copy_tool_dependencies tool_dir)
    if(ARGC GREATER 1)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${ARGN}")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS)
        if (CMAKE_MAJOR_VERSION VERSION_LESS 3 OR CMAKE_MINOR_VERSION VERSION_LESS 16)
            find_program(Z_VCPKG_POWERSHELL_CORE pwsh)
            if (NOT Z_VCPKG_POWERSHELL_CORE)
                message(FATAL_ERROR "Could not find PowerShell Core; please open an issue to report this.")
            endif()
        endif()
        cmake_path(RELATIVE_PATH tool_dir
            BASE_DIRECTORY "${CURRENT_PACKAGES_DIR}"
            OUTPUT_VARIABLE relative_tool_dir
        )
        if(relative_tool_dir MATCHES "/debug/")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_PACKAGES_DIR}/debug/bin")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_INSTALLED_DIR}/debug/bin")
        else()
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_PACKAGES_DIR}/bin")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_INSTALLED_DIR}/bin")
        endif()
    endif()
endfunction()
