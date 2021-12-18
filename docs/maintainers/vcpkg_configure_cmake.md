# vcpkg_configure_cmake

**This function has been deprecated in favor of [`vcpkg_cmake_configure`](ports/vcpkg-cmake/vcpkg_cmake_configure.md) from the vcpkg-cmake port.**

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_configure_cmake.md).

Configure CMake for Debug and Release builds of a project.

## Usage
```cmake
vcpkg_configure_cmake(
    SOURCE_PATH <${SOURCE_PATH}>
    [PREFER_NINJA]
    [DISABLE_PARALLEL_CONFIGURE]
    [NO_CHARSET_FLAG]
    [GENERATOR <"NMake Makefiles">]
    [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
    [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
    [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
    [MAYBE_UNUSED_VARIABLES <OPTION_NAME>...]
)
```

## Parameters
### SOURCE_PATH
Specifies the directory containing the `CMakeLists.txt`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PREFER_NINJA
Indicates that, when available, Vcpkg should use Ninja to perform the build.
This should be specified unless the port is known to not work under Ninja.

### DISABLE_PARALLEL_CONFIGURE
Disables running the CMake configure step in parallel.
This is needed for libraries which write back into their source directory during configure.

This also disables CMAKE_DISABLE_SOURCE_CHANGES.

### NO_CHARSET_FLAG
Disables passing `utf-8` as the default character set to `CMAKE_C_FLAGS` and `CMAKE_CXX_FLAGS`.

This is needed for libraries that set their own source code's character set.

### GENERATOR
Specifies the precise generator to use.

This is useful if some project-specific buildsystem has been wrapped in a cmake script that won't perform an actual build.
If used for this purpose, it should be set to `"NMake Makefiles"`.

### OPTIONS
Additional options passed to CMake during the configuration.

### OPTIONS_RELEASE
Additional options passed to CMake during the Release configuration. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to CMake during the Debug configuration. These are in addition to `OPTIONS`.

### MAYBE_UNUSED_VARIABLES
Any CMake variables which are explicitly passed in, but which may not be used on all platforms.
For example:
```cmake
vcpkg_cmake_configure(
    ...
    OPTIONS
        -DBUILD_EXAMPLE=OFF
    ...
    MAYBE_UNUSED_VARIABLES
        BUILD_EXAMPLE
)
```

### LOGNAME
Name of the log to write the output of the configure call to.

## Notes
This command supplies many common arguments to CMake. To see the full list, examine the source.

## Examples

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
* [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
* [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_configure\_cmake.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_configure_cmake.cmake)
