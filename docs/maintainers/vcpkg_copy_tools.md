# vcpkg_copy_tools

Copy tools and all their DLL dependencies into the tool folder.

## Usage
```cmake
vcpkg_copy_tools(
    [SEARCH_DIR <${CURRENT_PACKAGES_DIR}/bin>]
    [TOOL_NAMES <tool1>...]
    [VERBOSE]
)
```

```cmake
vcpkg_copy_tools([tool1]...)
```
## Parameters
### SEARCH_DIR
The path to the directory containing the tools. This will be set to `${CURRENT_PACKAGES_DIR}/bin` if ommited.

### TOOL_NAMES
A list of tool filenames without extension.

### VERBOSE
Display more messages for debugging purpose.

## Examples

* [czmq](https://github.com/microsoft/vcpkg/blob/master/ports/czmq/portfile.cmake)
* [nanomsg](https://github.com/microsoft/vcpkg/blob/master/ports/nanomsg/portfile.cmake)

## Source
[scripts/cmake/vcpkg_copy_tools.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_copy_tools.cmake)
