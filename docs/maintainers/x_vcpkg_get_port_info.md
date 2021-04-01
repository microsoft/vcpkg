# x_vcpkg_get_port_info

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/x_vcpkg_get_port_info.md).

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

## Source
[scripts/cmake/x\_vcpkg\_get\_port\_info.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/x_vcpkg_get_port_info.cmake)
