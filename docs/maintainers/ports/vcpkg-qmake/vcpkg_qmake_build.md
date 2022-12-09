# vcpkg_qmake_build

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-qmake/vcpkg_qmake_build.md).

Build a qmake-based project, previously configured using vcpkg_qmake_configure.

```cmake
vcpkg_qmake_configure(
    [SKIP_MAKEFILES]
    [BUILD_LOGNAME arg1]
    [TARGETS arg1 [arg2 ...]]
    [RELEASE_TARGETS arg1 [arg2 ...]]
    [DEBUG_TARGETS arg1 [arg2 ...]]
)
```

### SKIP_MAKEFILES
Skip the generation of makefiles

### BUILD_LOGNAME
Configuration independent prefix for the build log files (default:'build')

### TARGETS, RELEASE\_TARGETS, DEBUG\_TARGETS
Targets to build for a certain configuration.

## Source
[ports/vcpkg-qmake/vcpkg\_qmake\_configure.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-qmake/vcpkg_qmake_build.cmake)
