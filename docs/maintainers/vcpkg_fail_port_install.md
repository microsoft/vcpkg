# vcpkg_fail_port_install

Fails the current portfile with a (default) error message

## Usage
```cmake
vcpkg_fail_port_install([MESSAGE <message>] 	[ON_TARGET <target1> [<target2> ...]]
```

## Parameters
### MESSAGE
Additional failure message. If non is given a default message will be displayed depending on the failure condition

### ALWAYS
will always fail early

### ON_TARGET
targets for which the build should fail early. Valid targets are <target> from VCPKG_IS_TARGET_<target> (see vcpkg_common_definitions.cmake)

### ON_ARCH
architecture for which the build should fail early. 

### ON_CRT_LINKAGE
CRT linkage for which the build should fail early.

### ON_LIBRARY_LINKAGE
library linkage for which the build should fail early.

## Examples

* [aws-lambda-cpp](https://github.com/Microsoft/vcpkg/blob/master/ports/aws-lambda-cpp/portfile.cmake)

## Source
[scripts/cmake/vcpkg_fail_port_install.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_fail_port_install.cmake)
