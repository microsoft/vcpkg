# vcpkg_copy_tool_dependencies

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_copy_tool_dependencies.md).

Copy all DLL dependencies of built tools into the tool folder.

## Usage
```cmake
vcpkg_copy_tool_dependencies(<${CURRENT_PACKAGES_DIR}/tools/${PORT}>)
```
## Parameters
The path to the directory containing the tools.

## Notes
This command should always be called by portfiles after they have finished rearranging the binary output, if they have any tools.

## Examples

* [glib](https://github.com/Microsoft/vcpkg/blob/master/ports/glib/portfile.cmake)
* [fltk](https://github.com/Microsoft/vcpkg/blob/master/ports/fltk/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_copy\_tool\_dependencies.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_copy_tool_dependencies.cmake)
