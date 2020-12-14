# vcpkg_write_sourcelink_file

Write a Source Link file (if enabled). Internal function not for direct use by ports.

## Usage:
```cmake
vcpkg_write_sourcelink_file(
     SOURCE_PATH <path>
     SERVER_PATH <URL>
)
```

## Parameters:
### SOURCE_PATH
Specifies the local location of the sources used for build.

### SERVER_PATH
Specified the permanent location of the corresponding sources.

## Source
[scripts/cmake/vcpkg_write_sourcelink_file.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_write_sourcelink_file.cmake)
