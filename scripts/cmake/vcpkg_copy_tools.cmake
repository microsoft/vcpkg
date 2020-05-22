## # vcpkg_copy_tools
##
## Copy tools and all their DLL dependencies into the `tools` folder.
##
## ## Usage
## ```cmake
## vcpkg_copy_tools(
##     TOOL_NAMES <tool1>...
##     [SEARCH_DIR <${CURRENT_PACKAGES_DIR}/bin>]
##     [AUTO_CLEAN]
## )
## ```
## ## Parameters
## ### TOOL_NAMES
## A list of tool filenames without extension.
##
## ### SEARCH_DIR
## The path to the directory containing the tools. This will be set to `${CURRENT_PACKAGES_DIR}/bin` if ommited.
##
## ### AUTO_CLEAN
## Auto clean executables in `${CURRENT_PACKAGES_DIR}/bin` and `${CURRENT_PACKAGES_DIR}/debug/bin`.
##
## ## Examples
##
## * [cpuinfo](https://github.com/microsoft/vcpkg/blob/master/ports/cpuinfo/portfile.cmake)
## * [nanomsg](https://github.com/microsoft/vcpkg/blob/master/ports/nanomsg/portfile.cmake)
## * [uriparser](https://github.com/microsoft/vcpkg/blob/master/ports/uriparser/portfile.cmake)
function(vcpkg_copy_tools)
    cmake_parse_arguments(_vct "AUTO_CLEAN" "SEARCH_DIR" "TOOL_NAMES" ${ARGN})

    if(NOT DEFINED _vct_TOOL_NAMES)
        message(FATAL_ERROR "TOOL_NAMES must be specified.")
    endif()

    if(NOT DEFINED _vct_SEARCH_DIR)
        set(_vct_SEARCH_DIR ${CURRENT_PACKAGES_DIR}/bin)
    elseif(NOT IS_DIRECTORY ${_vct_SEARCH_DIR})
        message(FATAL_ERROR "SEARCH_DIR ${_vct_SEARCH_DIR} is supposed to be a directory.")
    endif()

    foreach(tool_name ${_vct_TOOL_NAMES})
        set(tool_path "${_vct_SEARCH_DIR}/${tool_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")

        if(EXISTS ${tool_path})
            file(COPY ${tool_path} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        else()
            message(FATAL_ERROR "Couldn't find this tool: ${tool_path}.")
        endif()
    endforeach()

    if(_vct_AUTO_CLEAN)
        vcpkg_clean_executables_in_bin(FILE_NAMES ${_vct_TOOL_NAMES})
    endif()

    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endfunction()
