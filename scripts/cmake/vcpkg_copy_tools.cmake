#[===[.md:
# vcpkg_copy_tools

Copy tools and all their DLL dependencies into the `tools` folder.

## Usage
```cmake
vcpkg_copy_tools(
    TOOL_NAMES <tool1>...
    [SEARCH_DIR <${CURRENT_PACKAGES_DIR}/bin>]
    [DESTINATION <${CURRENT_PACKAGES_DIR}/tools/${PORT}>]
    [AUTO_CLEAN]
)
```
## Parameters
### TOOL_NAMES
A list of tool filenames without extension.

### SEARCH_DIR
The path to the directory containing the tools. This will be set to `${CURRENT_PACKAGES_DIR}/bin` if omitted.

### DESTINATION
Destination to copy the tools to. This will be set to `${CURRENT_PACKAGES_DIR}/tools/${PORT}` if omitted.

### AUTO_CLEAN
Auto clean executables in `${CURRENT_PACKAGES_DIR}/bin` and `${CURRENT_PACKAGES_DIR}/debug/bin`.

## Examples

* [cpuinfo](https://github.com/microsoft/vcpkg/blob/master/ports/cpuinfo/portfile.cmake)
* [nanomsg](https://github.com/microsoft/vcpkg/blob/master/ports/nanomsg/portfile.cmake)
* [uriparser](https://github.com/microsoft/vcpkg/blob/master/ports/uriparser/portfile.cmake)
#]===]

function(vcpkg_copy_tools)
    cmake_parse_arguments(PARSE_ARGV 0 arg "AUTO_CLEAN" "SEARCH_DIR;DESTINATION" "TOOL_NAMES")

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_TOOL_NAMES)
        message(FATAL_ERROR "TOOL_NAMES must be specified.")
    endif()

    if(NOT DEFINED arg_DESTINATION)
        set(arg_DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()

    if(NOT DEFINED arg_SEARCH_DIR)
        set(arg_SEARCH_DIR "${CURRENT_PACKAGES_DIR}/bin")
    elseif(NOT IS_DIRECTORY "${arg_SEARCH_DIR}")
        message(FATAL_ERROR "SEARCH_DIR (${arg_SEARCH_DIR}) must be a directory")
    endif()

    foreach(tool_name IN LISTS arg_TOOL_NAMES)
        set(tool_path "${arg_SEARCH_DIR}/${tool_name}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        set(tool_pdb "${arg_SEARCH_DIR}/${tool_name}.pdb")
        if(EXISTS "${tool_path}")
            file(COPY "${tool_path}" DESTINATION "${arg_DESTINATION}")
        else()
            message(FATAL_ERROR "Couldn't find tool \"${tool_name}\":
    \"${tool_path}\" does not exist")
        endif()
        if(EXISTS "${tool_pdb}")
            file(COPY "${tool_pdb}" DESTINATION "${arg_DESTINATION}")
        endif()
    endforeach()

    if(arg_AUTO_CLEAN)
        vcpkg_clean_executables_in_bin(FILE_NAMES ${arg_TOOL_NAMES})
    endif()

    vcpkg_copy_tool_dependencies("${arg_DESTINATION}")
endfunction()
