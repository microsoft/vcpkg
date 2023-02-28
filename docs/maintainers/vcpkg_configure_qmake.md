# vcpkg_configure_qmake

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_configure_qmake.md).

Configure a qmake-based project.

```cmake
vcpkg_configure_qmake(
    SOURCE_PATH <pro_file_path>
    [OPTIONS arg1 [arg2 ...]]
    [OPTIONS_RELEASE arg1 [arg2 ...]]
    [OPTIONS_DEBUG arg1 [arg2 ...]]
    [BUILD_OPTIONS arg1 [arg2 ...]]
    [BUILD_OPTIONS_RELEASE arg1 [arg2 ...]]
    [BUILD_OPTIONS_DEBUG arg1 [arg2 ...]]
)
```

### SOURCE_PATH
The path to the *.pro qmake project file.

### OPTIONS, OPTIONS\_RELEASE, OPTIONS\_DEBUG
The options passed to qmake to the configure step.

### BUILD\_OPTIONS, BUILD\_OPTIONS\_RELEASE, BUILD\_OPTIONS\_DEBUG
The options passed to qmake to the build step.

## Source
[scripts/cmake/vcpkg\_configure\_qmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_qmake.cmake)
