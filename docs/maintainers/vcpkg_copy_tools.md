# vcpkg_copy_tools

Copy tools and all their DLL dependencies into the `tools` folder.

## Usage
```cmake
vcpkg_copy_tools(
    TOOL_NAMES <tool1>...
    [SEARCH_DIR <${CURRENT_PACKAGES_DIR}/bin>]
    [AUTO_CLEAN]
)
```
## Parameters
### TOOL_NAMES
A list of tool filenames without extension.

### SEARCH_DIR
The path to the directory containing the tools. This will be set to `${CURRENT_PACKAGES_DIR}/bin` if ommited.

### AUTO_CLEAN
Auto clean executables in `${CURRENT_PACKAGES_DIR}/bin` and `${CURRENT_PACKAGES_DIR}/debug/bin`.

## Examples

* [cpuinfo](https://github.com/microsoft/vcpkg/blob/master/ports/cpuinfo/portfile.cmake)
* [nanomsg](https://github.com/microsoft/vcpkg/blob/master/ports/nanomsg/portfile.cmake)
* [uriparser](https://github.com/microsoft/vcpkg/blob/master/ports/uriparser/portfile.cmake)

## Source
[scripts/cmake/vcpkg_copy_tools.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_copy_tools.cmake)
