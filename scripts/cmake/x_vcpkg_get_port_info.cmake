#[===[.md:
# x_vcpkg_get_port_info

Experimental
Retrieve port information (e.g. installed features) of an already installed port.

## Usage
```cmake
x_vcpkg_get_port_info(
    PORTS <portname>...
)
```
## Parameters
### PORTS
List of ports to retrieve information about.
Information will be stored in:
<PORT>_FEATURES: features <PORT> was installed with
<PORT>_LIBRARY_LINKAGE: VCPKG_LIBRARY_LINKAGE <PORT> was installed with

## Examples

* [pcl](https://github.com/microsoft/vcpkg/blob/master/ports/pcl/portfile.cmake)
#]===]
function(x_vcpkg_get_port_info)
    cmake_parse_arguments(PARSE_ARGV 0 x_vcpkg_get_port_info "" "" "PORTS")
    if(NOT x_vcpkg_get_port_info_PORTS)
        message(FATAL_ERROR "x_vcpkg_get_port_info requires parameter PORTS!")
    endif()
    string(TOLOWER "${x_vcpkg_get_port_info_PORTS}" x_vcpkg_get_port_info_PORTS)

    foreach(_port IN LISTS x_vcpkg_get_port_info_PORTS )
        set(_port_info "${CURRENT_INSTALLED_DIR}/share/${_port}/vcpkg_port_info.cmake") 
        if(EXISTS "${_port_info}")
            include("${_port_info}")
        endif()
        set(${_port}_FEATURES "${${_port}_FEATURES}" PARENT_SCOPE)
    endforeach()
endfunction()

# Write information about the port. Keep in sync with x_vcpkg_get_port_info
function(z_vcpkg_write_port_info)
    set(_file "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg_port_info.cmake")
    set(_contents "set(${PORT}_FEATURES \"${FEATURES}\")\n")
    string(APPEND _contents "set(${PORT}_LIBRARY_LINKAGE \"${VCPKG_LIBRARY_LINKAGE}\")\n")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    file(WRITE "${_file}" "${_contents}")
endfunction()