function(z_vcpkg_copy_tool_dependencies_search tool_dir path_to_search)
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
        if(relative_tool_dir MATCHES "^debug/|/debug/")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_PACKAGES_DIR}/debug/bin")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_INSTALLED_DIR}/debug/bin")
        else()
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_PACKAGES_DIR}/bin")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_INSTALLED_DIR}/bin")
        endif()
    endif()
endfunction()
