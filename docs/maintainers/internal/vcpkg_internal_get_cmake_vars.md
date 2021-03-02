# vcpkg_internal_get_cmake_vars

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/).

**Only for internal use in vcpkg helpers. Behavior and arguments will change without notice.**
Runs a cmake configure with a dummy project to extract certain cmake variables

## Usage
```cmake
vcpkg_internal_get_cmake_vars(
    [OUTPUT_FILE <output_file_with_vars>]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
)
```

## Parameters
### OPTIONS
Additional options to pass to the test configure call 

### OUTPUT_FILE
Variable to return the path to the generated cmake file with the detected `CMAKE_` variables set as `VCKPG_DETECTED_`

## Notes
If possible avoid usage in portfiles. 

## Examples

* [vcpkg_configure_make](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_make.cmake)

## Source
[scripts/cmake/vcpkg\_internal\_get\_cmake\_vars.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_internal_get_cmake_vars.cmake)
