function(z_vcpkg_copy_tool_dependencies_search tool_dir path_to_search)
    if(DEFINED Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT)
        set(count ${Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT})
    else()
        set(count 0)
    endif()
    file(GLOB tools "${tool_dir}/*.exe" "${tool_dir}/*.dll" "${tool_dir}/*.pyd")
    foreach(tool IN LISTS tools)
        set(log_out "${CURRENT_BUILDTREES_DIR}/copy-tool-dependencies-${count}-out.log")
        set(log_err "${CURRENT_BUILDTREES_DIR}/copy-tool-dependencies-${count}-err.log")
        set(copied_files_log "${CURRENT_BUILDTREES_DIR}/copy-tool-dependencies-${count}-copied-files.log")
        file(REMOVE "${copied_files_log}")
        if(VCPKG_USE_LEGACY_APPLOCAL)
            vcpkg_execute_in_download_mode(
                COMMAND "${Z_VCPKG_POWERSHELL_CORE}" -noprofile -executionpolicy Bypass -file "${VCPKG_ROOT_DIR}/scripts/buildsystems/msbuild/applocal.ps1"
                    -targetBinary "${tool}"
                    -installedDir "${path_to_search}"
                    -OutVariable out
                RESULT_VARIABLE error_code
                OUTPUT_VARIABLE out_var
                ERROR_VARIABLE err_var
                WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
            )
        else()
            vcpkg_execute_in_download_mode(
                COMMAND "$ENV{VCPKG_COMMAND}" z-applocal
                    "--target-binary=${tool}"
                    "--installed-bin-dir=${path_to_search}"
                    "--copied-files-log=${copied_files_log}"
                RESULT_VARIABLE error_code
                OUTPUT_VARIABLE out_var
                ERROR_VARIABLE err_var
                WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
            )
        endif()
        file(WRITE "${log_out}" "${out_var}")
        if(EXISTS "${copied_files_log}")
            file(READ "${copied_files_log}" copied_files)
            file(APPEND "${log_out}" "${copied_files}")
        endif()
        file(WRITE "${log_err}" "${err_var}")
        if(NOT error_code STREQUAL "0" AND VCPKG_VERBOSE)
            message(STATUS "vcpkg failed to copy dependencies for ${tool}; see ${log_out} and ${log_err}.")
        endif()
        math(EXPR count "${count} + 1")
    endforeach()
    set(Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT ${count} CACHE INTERNAL "")
endfunction()

function(vcpkg_copy_tool_dependencies tool_dir)
    if(ARGC GREATER 1)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${ARGN}")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS)
        if(VCPKG_USE_LEGACY_APPLOCAL)
            vcpkg_find_acquire_program(PWSH)
            set(Z_VCPKG_POWERSHELL_CORE "${PWSH}")
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
