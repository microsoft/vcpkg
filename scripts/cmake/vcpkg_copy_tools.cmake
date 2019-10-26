## # vcpkg_copy_tools
##
## Copy tools and all their DLL dependencies into the tool folder.
##
## ## Usage
## ```cmake
## vcpkg_copy_tools(
##     [SEARCH_DIR <${CURRENT_PACKAGES_DIR}/bin>]
##     [TOOL_NAMES <tool1>...]
##     [VERBOSE]
## )
## ```
##
## ```cmake
## vcpkg_copy_tools([tool1]...)
## ```
## ## Parameters
## ### SEARCH_DIR
## The path to the directory containing the tools. This will be set to `${CURRENT_PACKAGES_DIR}/bin` if ommited.
##
## ### TOOL_NAMES
## A list of tool filenames without extension.
##
## ### VERBOSE
## Display more messages for debugging purpose.
##
## ## Examples
##
## * [czmq](https://github.com/microsoft/vcpkg/blob/master/ports/czmq/portfile.cmake)
## * [nanomsg](https://github.com/microsoft/vcpkg/blob/master/ports/nanomsg/portfile.cmake)
function(vcpkg_copy_tools)
    cmake_parse_arguments(_vct "VERBOSE" "SEARCH_DIR" "TOOL_NAMES" ${ARGN})

    if((DEFINED _vct_SEARCH_DIR OR DEFINED _vct_VERBOSE) AND NOT DEFINED _vct_TOOL_NAMES)
        message(FATAL_ERROR "TOOL_NAMES should be specified if SEARCH_DIR or VERBOSE is specified.")
    endif()

    if(NOT DEFINED _vct_SEARCH_DIR)
        set(_vct_SEARCH_DIR ${CURRENT_PACKAGES_DIR}/bin)
    elseif(NOT IS_DIRECTORY ${_vct_SEARCH_DIR})
        message(FATAL_ERROR "SEARCH_DIR ${_vct_SEARCH_DIR} is supposed to be a directory.")
    endif()

    if(NOT DEFINED _vct_TOOL_NAMES)
        set(_vct_TOOL_NAMES ${ARGN})
    endif()

    foreach(tool_name ${_vct_TOOL_NAMES})
        set(tool_path "${_vct_SEARCH_DIR}/${tool_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")

        if(EXISTS ${tool_path})
            file(COPY ${tool_path} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        else()
            if(_vct_VERBOSE)
                message(STATUS "Couldn't find this tool: ${tool_path}.")
            endif()
        endif()

        file(REMOVE
            ${CURRENT_PACKAGES_DIR}/bin/${tool_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/${tool_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        )
    endif()

    # Do remaining cleaning work
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        if(VCPKG_TARGET_IS_WINDOWS)
            file(GLOB exes_ignored ${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX})

            foreach(ignored_exe ${exes_ignored})
                if(_vct_VERBOSE)
                    message(STATUS "${ignored_exe} is not installed, will be deleted.")
                endif()

                file(REMOVE ${ignored_exe})
            endforeach()
        endif()
    else()
        if(_vct_VERBOSE)
            file(GLOB tools_ignored ${CURRENT_PACKAGES_DIR}/bin/*.*)

            foreach(ignored_tool ${tools_ignored})
                message(STATUS "${ignored_tool} is not installed, will be deleted.")
            endforeach()
        endif()

        file(REMOVE_RECURSE
            ${CURRENT_PACKAGES_DIR}/bin
            ${CURRENT_PACKAGES_DIR}/debug/bin
        )
    endif()

    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endfunction()
