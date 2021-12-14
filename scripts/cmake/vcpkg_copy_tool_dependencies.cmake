#[===[.md:
# vcpkg_copy_tool_dependencies

Copy all DLL dependencies of built tools into the tool folder.

## Usage
```cmake
vcpkg_copy_tool_dependencies(
    <${CURRENT_PACKAGES_DIR}/tools/${PORT}>
    [DEPENDENCIES <dep1>...]
)
```
## tool_dir
The path to the directory containing the tools. This will be set to `${CURRENT_PACKAGES_DIR}/tools/${PORT}` if omitted.

## DEPENDENCIES
A list of dynamic libraries a tool is likely to load at runtime, such as plugins,
or other Run-Time Dynamic Linking mechanisms like LoadLibrary or dlopen.
These libraries will be copied into the same directory as the tool
even if they are not statically determined as dependencies from inspection of their import tables.

## Notes
This command should always be called by portfiles after they have finished rearranging the binary output, if they have any tools.

## Examples

* [glib](https://github.com/Microsoft/vcpkg/blob/master/ports/glib/portfile.cmake)
* [fltk](https://github.com/Microsoft/vcpkg/blob/master/ports/fltk/portfile.cmake)
#]===]

function(z_vcpkg_copy_tool_dependencies_search tool_dir path_to_search dependencies)
    if(DEFINED Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT)
        set(count ${Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT})
    else()
        set(count 0)
    endif()

    file(GLOB tools "${tool_dir}/*.exe" "${tool_dir}/*.dll" "${tool_dir}/*.pyd")
    if (dependencies)
        foreach (SEARCH_ITEM IN_LIST dependencies)
        if (EXISTS "${CURRENT_PACKAGES_DIR}/bin/${SEARCH_ITEM}")
            debug_message("Copying file ${CURRENT_PACKAGES_DIR}/bin/${SEARCH_ITEM} to ${TOOL_DIR}")
            file(COPY "${CURRENT_PACKAGES_DIR}/bin/${SEARCH_ITEM}" DESTINATION "${TOOL_DIR}")
            vcpkg_list(APPEND tools "${TOOL_DIR}/${SEARCH_ITEM}")    
        else()
            message(WARNING "Dynamic dependency ${SEARCH_ITEM} not found in ${CURRENT_PACKAGES_DIR}/bin.")
            endif()
        endforeach()
    endif()

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
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "" "DEPENDENCIES")
    if(ARGC GREATER 2)
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
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_PACKAGES_DIR}/debug/bin" "${arg_DEPENDENCIES}")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_INSTALLED_DIR}/debug/bin" "${arg_DEPENDENCIES}")
        else()
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_PACKAGES_DIR}/bin" "${arg_DEPENDENCIES}")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_INSTALLED_DIR}/bin" "${arg_DEPENDENCIES}")
        endif()
    endif()
endfunction()
