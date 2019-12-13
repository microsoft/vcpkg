# vcpkg_get_port_version_base

This is a convenience function to get the base version of the current port.
The base version refers to the port version without the modification
number.

Given a port version in the format described in the CONTROL files docs,
this function attempts to get the base part of the version from the
version specified in the portfile.

This function should not be used when the version is specified as a date or
if the version contains dashes as part of the base version.

## Usage:
```cmake
vcpkg_get_port_version_base( PORT_BASE_VERSION )
```

## Examples:
```cmake
# With PORT_VERSION = 1.2.3
vcpkg_get_port_version_base( PORT_BASE_VERSION ) # Results in 1.2.3
# With PORT_VERSION = 1.2.3-2
vcpkg_get_port_version_base( PORT_BASE_VERSION ) # Results in 1.2.3
```

## Parameters:

### PORT_BASE_VERSION
Name of the variable that will contain the resulting version string.


## Source
[scripts/cmake/vcpkg_get_port_version_base.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_get_port_version_base.cmake)
