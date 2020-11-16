## # vcpkg_copy_tool_dependencies
##
## Copy all DLL dependencies of built tools into the tool folder.
##
## ## Usage
## ```cmake
## vcpkg_copy_tool_dependencies(<${CURRENT_PACKAGES_DIR}/tools/${PORT}>)
## ```
## ## Parameters
## The path to the directory containing the tools.
##
## ## Notes
## This command should always be called by portfiles after they have finished rearranging the binary output, if they have any tools.
##
## ## Examples
##
## * [glib](https://github.com/Microsoft/vcpkg/blob/master/ports/glib/portfile.cmake)
## * [fltk](https://github.com/Microsoft/vcpkg/blob/master/ports/fltk/portfile.cmake)
function(vcpkg_copy_tool_dependencies TOOL_DIR)
    if (VCPKG_TARGET_IS_WINDOWS)
        find_program(PWSH_EXE pwsh)
        if (NOT PWSH_EXE)
            message(FATAL_ERROR "Could not find PowerShell Core; please open an issue to report this.")
        endif()
        macro(search_for_dependencies PATH_TO_SEARCH)
            file(GLOB TOOLS "${TOOL_DIR}/*.exe" "${TOOL_DIR}/*.dll")
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
    endif()
endfunction()
