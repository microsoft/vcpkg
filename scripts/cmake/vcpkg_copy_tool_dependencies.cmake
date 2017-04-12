# Copy dlls for all tools in TOOL_DIR

function(vcpkg_copy_tool_dependencies TOOL_DIR)
    macro(search_for_dependencies PATH_TO_SEARCH)
        file(GLOB TOOLS ${TOOL_DIR}/*.exe ${TOOL_DIR}/*.dll)
        foreach(TOOL ${TOOLS})
            execute_process(COMMAND powershell -noprofile -executionpolicy Bypass -nologo
                -file ${VCPKG_ROOT_DIR}/scripts/buildsystems/msbuild/applocal.ps1
                -targetBinary ${TOOL}
                -installedDir ${PATH_TO_SEARCH}
                OUTPUT_VARIABLE OUT)
        endforeach()
    endmacro()
    search_for_dependencies(${CURRENT_PACKAGES_DIR}/bin)
    search_for_dependencies(${CURRENT_INSTALLED_DIR}/bin)
endfunction()
