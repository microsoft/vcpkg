#[===[.md:
# vcpkg_copy_tool_dependencies

Copy all DLL dependencies of built tools into the tool folder.

## Usage
```cmake
vcpkg_copy_tool_dependencies(<${CURRENT_PACKAGES_DIR}/tools/${PORT}>)
```
## Parameters
The path to the directory containing the tools.

## Notes
This command should always be called by portfiles after they have finished rearranging the binary output, if they have any tools.

## Examples

* [glib](https://github.com/Microsoft/vcpkg/blob/master/ports/glib/portfile.cmake)
* [fltk](https://github.com/Microsoft/vcpkg/blob/master/ports/fltk/portfile.cmake)
#]===]

function(z_vcpkg_copy_tool_dependencies_search tool_dir path_to_search)
    file(GLOB tools "${tool_dir}/*.exe" "${tool_dir}/*.dll" "${tool_dir}/*.pyd")
    foreach(tool IN LISTS tools)
        vcpkg_execute_required_process(
            COMMAND "${Z_VCPKG_POWERSHELL_CORE}" -noprofile -executionpolicy Bypass -nologo
                -file "${SCRIPTS}/buildsystems/msbuild/applocal.ps1"
                -targetBinary "${tool}"
                -installedDir "${path_to_search}"
            WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
            LOGNAME copy-tool-dependencies
        )
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
        z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_PACKAGES_DIR}/bin")
        z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_INSTALLED_DIR}/bin")
    endif()
endfunction()
