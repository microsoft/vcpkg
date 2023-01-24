# vcpkg_qmake_install

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-qmake/vcpkg_qmake_install.md).

Build and install a qmake project.


```cmake
vcpkg_qmake_install(...)
```

### Parameters:
See [`vcpkg_qmake_build()`](vcpkg_qmake_build.md).

### Notes:
This command transparently forwards to [`vcpkg_qmake_build()`](vcpkg_qmake_build.md)
and appends the 'install' target

## Source
[ports/vcpkg-qmake/vcpkg\_qmake\_configure.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-qmake/vcpkg_qmake_install.cmake)
