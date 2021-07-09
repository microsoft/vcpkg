#[===[.md:
# vcpkg_copy_tool_dependencies

Copy all DLL dependencies of built tools into the tool folder.

## Usage
```cmake
vcpkg_copy_tool_dependencies(
    [TOOL_DIR <${CURRENT_PACKAGES_DIR}/tools/${PORT}>]
    [DEPENDENCIES <dep1>...]
)
```
## TOOL_DIR
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

function(vcpkg_copy_tool_dependencies)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "TOOL_DIR" "DEPENDENCIES")
    
    if (NOT DEFINED arg_TOOL_DIR)
        set(arg_TOOL_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()

    if (VCPKG_TARGET_IS_WINDOWS)
        find_program(PWSH_EXE pwsh)
        if (NOT PWSH_EXE)
            if(UNIX AND NOT CYGWIN)
                message(FATAL_ERROR "Could not find PowerShell Core; install PowerShell Core as described here: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux")
            endif()
            message(FATAL_ERROR "Could not find PowerShell Core; please open an issue to report this.")
        endif()
        macro(search_for_dependencies PATH_TO_SEARCH)
            file(GLOB TOOLS "${arg_TOOL_DIR}/*.exe" "${arg_TOOL_DIR}/*.dll" "${arg_TOOL_DIR}/*.pyd")
            foreach(TOOL IN LISTS TOOLS)
                vcpkg_execute_required_process(
                    COMMAND "${PWSH_EXE}" -noprofile -executionpolicy Bypass -nologo
                        -file "${SCRIPTS}/buildsystems/msbuild/applocal.ps1"
                        -targetBinary "${TOOL}"
                        -installedDir "${PATH_TO_SEARCH}"
                    WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
                    LOGNAME copy-tool-dependencies
                )
            endforeach()
        endmacro()
        search_for_dependencies("${CURRENT_PACKAGES_DIR}/bin")
        search_for_dependencies("${CURRENT_INSTALLED_DIR}/bin")
        
        if (arg_DEPENDENCIES)
            foreach (SEARCH_ITEM IN_LIST ${arg_DEPENDENCIES})
                if (EXISTS "${CURRENT_PACKAGES_DIR}/bin/${SEARCH_ITEM}")
                    debug_message("Copying file ${CURRENT_PACKAGES_DIR}/bin/${SEARCH_ITEM} to ${arg_TOOL_DIR}")
                    file(COPY "${CURRENT_PACKAGES_DIR}/bin/${SEARCH_ITEM}" DESTINATION "${arg_TOOL_DIR}")
                else()
                    message(WARNING "Dynamic dependency ${SEARCH_ITEM} not found in ${CURRENT_PACKAGES_DIR}/bin.")
                endif()
            endforeach()
        endif()
    endif()
endfunction()
