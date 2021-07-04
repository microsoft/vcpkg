#[===[
# vcpkg_add_to_path

Add a directory or directories to the PATH environment variable

```cmake
vcpkg_add_to_path([PREPEND] [<path>...])
```

`vcpkg_add_to_path` adds all of the paths passed to it to the PATH environment variable.
If PREPEND is passed, then those paths are prepended to the PATH environment variable,
so that they are searched first; otherwise, those paths are appended, so they are
searched after the paths which are already in the environment variable.

The paths are added in the order received, so that the first path is always searched
before a later path.

If no paths are passed, then nothing will be done.

## Examples:
* [curl](https://github.com/Microsoft/vcpkg/blob/master/ports/curl/portfile.cmake#L75)
* [folly](https://github.com/Microsoft/vcpkg/blob/master/ports/folly/portfile.cmake#L15)
* [z3](https://github.com/Microsoft/vcpkg/blob/master/ports/z3/portfile.cmake#L13)
#]===]
function(vcpkg_add_to_path)
    cmake_parse_arguments(PARSE_ARGV 0 "arg" "PREPEND" "" "")
    if(NOT DEFINED arg_UNPARSED_ARGUMENTS)
        return()
    endif()

    list(JOIN arg_UNPARSED_ARGUMENTS "${VCPKG_HOST_PATH_SEPARATOR}" add_to_path)
    if(arg_PREPEND)
        set(ENV{PATH} "${add_to_path}${VCPKG_HOST_PATH_SEPARATOR}$ENV{PATH}")
    else()
        set(ENV{PATH} "$ENV{PATH}${VCPKG_HOST_PATH_SEPARATOR}${add_to_path}")
    endif()
endfunction()
