# vcpkg_add_to_path

Add a directory to the PATH environment variable

## Usage
```cmake
vcpkg_add_to_path([PREPEND] <${PYTHON3_DIR}>)
```

## Parameters
### <positional>
The directory to add

### PREPEND
Prepends the directory.

The default is to append.

## Source
[scripts/cmake/vcpkg_add_to_path.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_add_to_path.cmake)
