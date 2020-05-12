# vcpkg_fail_port_install

Checks common requirements and fails the current portfile with a (default) error message

## Usage
```cmake
vcpkg_fail_port_install(
    [ALWAYS]
    [MESSAGE <"Reason for failure">]
    [ON_TARGET <Windows> [<OSX> ...]]
    [ON_ARCH <x64> [<arm> ...]]
    [ON_CRT_LINKAGE <static> [<dynamic> ...]])
    [ON_LIBRARY_LINKAGE <static> [<dynamic> ...]]
)
```

## Parameters
### MESSAGE
Additional failure message. If none is given, a default message will be displayed depending on the failure condition.

### ALWAYS
Will always fail early

### ON_TARGET
Targets for which the build should fail early. Valid targets are `<target>` from `VCPKG_IS_TARGET_<target>` (see `vcpkg_common_definitions.cmake`).

### ON_ARCH
Architecture for which the build should fail early.

### ON_CRT_LINKAGE
CRT linkage for which the build should fail early.

### ON_LIBRARY_LINKAGE
Library linkage for which the build should fail early.

## Examples

* [aws-lambda-cpp](https://github.com/Microsoft/vcpkg/blob/master/ports/aws-lambda-cpp/portfile.cmake)

## Source
[scripts/cmake/vcpkg_fail_port_install.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_fail_port_install.cmake)
