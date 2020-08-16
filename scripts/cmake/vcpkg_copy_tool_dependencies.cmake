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
    find_program(PS_EXE powershell PATHS ${DOWNLOADS}/tool)
    if (PS_EXE-NOTFOUND)
        message(FATAL_ERROR "Could not find powershell in vcpkg tools, please open an issue to report this.")
    endif()
    macro(search_for_dependencies PATH_TO_SEARCH)
        file(GLOB TOOLS ${TOOL_DIR}/*.exe ${TOOL_DIR}/*.dll)
        foreach(TOOL ${TOOLS})
            vcpkg_execute_required_process(
                COMMAND ${PS_EXE} -noprofile -executionpolicy Bypass -nologo
                    -file ${SCRIPTS}/buildsystems/msbuild/applocal.ps1
                    -targetBinary ${TOOL}
                    -installedDir ${PATH_TO_SEARCH}
                WORKING_DIRECTORY ${VCPKG_ROOT_DIR}
                LOGNAME copy-tool-dependencies
            )
        endforeach()
    endmacro()
    search_for_dependencies(${CURRENT_PACKAGES_DIR}/bin)
    search_for_dependencies(${CURRENT_INSTALLED_DIR}/bin)
endfunction()
