# vcpkg_configure_qmake

Configure a qmake-based project.

```cmake
vcpkg_configure_qmake(
    SOURCE_PATH <pro_file_path>
    [OPTIONS arg1 [arg2 ...]]
    [OPTIONS_RELEASE arg1 [arg2 ...]]
    [OPTIONS_DEBUG arg1 [arg2 ...]]
)
```

### SOURCE_PATH
The path to the *.pro qmake project file.

### OPTIONS, OPTIONS\_RELEASE, OPTIONS\_DEBUG
The options passed to qmake.

## Source
[scripts/cmake/vcpkg_configure_qmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_qmake.cmake)
