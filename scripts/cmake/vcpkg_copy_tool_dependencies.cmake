# Copy dlls for all tools in ${CURRENT_PACKAGES_DIR}/tools

function(vcpkg_copy_tool_dependencies)
    macro(search_for_dependencies PATH_TO_SEARCH)
        file(GLOB TOOLS ${CURRENT_PACKAGES_DIR}/tools/*.exe ${CURRENT_PACKAGES_DIR}/tools/*.dll)
        foreach(TOOL ${TOOLS})
            execute_process(COMMAND powershell -noprofile -executionpolicy UnRestricted -nologo
                -file ${VCPKG_ROOT_DIR}/scripts/buildsystems/msbuild/applocal.ps1
                -targetBinary ${TOOL}
                -installedDir ${PATH_TO_SEARCH}
                OUTPUT_VARIABLE OUT)
        endforeach()
    endmacro()
    search_for_dependencies(${CURRENT_PACKAGES_DIR}/bin)
    search_for_dependencies(${CURRENT_INSTALLED_DIR}/bin)
endfunction()
