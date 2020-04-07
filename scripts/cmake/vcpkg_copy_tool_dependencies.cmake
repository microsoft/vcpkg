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
    macro(search_for_dependencies PATH_TO_SEARCH)
        file(GLOB TOOLS ${TOOL_DIR}/*.exe ${TOOL_DIR}/*.dll)
        foreach(TOOL ${TOOLS})
            execute_process(COMMAND powershell -noprofile -executionpolicy Bypass -nologo
                -file ${SCRIPTS}/buildsystems/msbuild/applocal.ps1
                -targetBinary ${TOOL}
                -installedDir ${PATH_TO_SEARCH}
                OUTPUT_VARIABLE OUT)
        endforeach()
    endmacro()
    search_for_dependencies(${CURRENT_PACKAGES_DIR}/bin)
    search_for_dependencies(${CURRENT_INSTALLED_DIR}/bin)
endfunction()
