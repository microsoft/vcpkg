# vcpkg_cmake_configure

**The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_cmake_configure.md).**

Configure a CMake-based project.

## Usage

```cmake
vcpkg_cmake_configure(
    SOURCE_PATH <source-path>
    [DISABLE_PARALLEL_CONFIGURE]
    [NO_CHARSET_FLAG]
    [WINDOWS_USE_MSBUILD]
    [GENERATOR <generator>]
    [LOGFILE_BASE <logname-base>]
    [OPTIONS
        <configure-setting>...]
    [OPTIONS_RELEASE
        <configure-setting>...]
    [OPTIONS_DEBUG
        <configure-setting>...]
    [MAYBE_UNUSED_VARIABLES
        <option-name>...]
)
```

To use this function, you must depend on the helper port [`vcpkg-cmake`](ports/vcpkg-cmake.md):
```no-highlight
"dependencies": [
  {
    "name": "vcpkg-cmake",
    "host": true
  }
]
```

## Parameters

### SOURCE_PATH
Specifies the directory containing the `CMakeLists.txt`.

This value is usually obtained as a result of calling a source acquisition command like [`vcpkg_from_github()`](vcpkg_from_github.md).

### DISABLE_PARALLEL_CONFIGURE
Disables running the CMake configure step in parallel.

By default vcpkg disables writing back to the source directory (via the undocumented CMake flag `CMAKE_DISABLE_SOURCE_CHANGES`) and (on Windows) configures Release and Debug in parallel. This flag instructs vcpkg to allow source directory writes and to execute the configure steps sequentially.

### NO_CHARSET_FLAG
Disables passing `/utf-8` when using the [built-in Windows toolchain][VCPKG_CHAINLOAD_TOOLCHAIN_FILE].

This is needed for libraries that set their own source code's character set when targeting MSVC. See the [MSVC documentation for `/utf-8`](https://docs.microsoft.com/cpp/build/reference/utf-8-set-source-and-executable-character-sets-to-utf-8) for more information.

### WINDOWS_USE_MSBUILD
Use MSBuild instead of another generator when targeting a Windows platform.

By default vcpkg prefers to use Ninja as the CMake Generator for all platforms. However, there are edge cases where MSBuild has different behavior than Ninja. This flag should only be passed if the project requires MSBuild to build correctly.
This flag has no effect for MinGW targets.

### GENERATOR
Specifies the Generator to use.

By default vcpkg prefers to use Ninja as the CMake Generator for all platforms,
or "Unix Makefiles" for non-Windows platforms when Ninja is not available.
This parameter can be used for edge cases where project-specific buildsystems depend on a particular generator.

### LOGFILE_BASE
An alternate root name for the configure logs.

Defaults to `config-${TARGET_TRIPLET}`. It should not contain any path separators. Logs will be generated matching the pattern `${CURRENT_BUILDTREES_DIR}/${LOGFILE_BASE}-<suffix>.log`

### OPTIONS
Additional options to pass to CMake during the configuration.

See also [Implicit Options](#implicit-options).

### OPTIONS_RELEASE
Additional options to pass to CMake during the Release configuration.

These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options to pass to CMake during the Debug configuration.

These are in addition to `OPTIONS`.

### MAYBE_UNUSED_VARIABLES
List of CMake options that may not be read during the configure step.

vcpkg will warn about any options outside this list that were not read during the CMake configure step. This list should contain options that are only read during certain configurations (such as when `VCPKG_LIBRARY_LINKAGE` is `"static"` or when certain features are enabled).

## Implicit Options
This command automatically provides several options to CMake.

- [`CMAKE_BUILD_TYPE`](https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html) is set to `"Release"` or `"Debug"` as appropriate.
- [`BUILD_SHARED_LIBS`](https://cmake.org/cmake/help/latest/variable/BUILD_SHARED_LIBS.html) is set according to the value of [`VCPKG_LIBRARY_LINKAGE`](../users/triplets.md#vcpkg_library_linkage).
- [`CMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}</debug>`](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html) as appropriate to the configuration
- [`CMAKE_TOOLCHAIN_FILE`](https://cmake.org/cmake/help/latest/variable/CMAKE_TOOLCHAIN_FILE.html) and `VCPKG_CHAINLOAD_TOOLCHAIN_FILE` are set to include the [vcpkg toolchain file](../users/buildsystems/cmake-integration.md#cmake_toolchain_file) and the [triplet toolchain][VCPKG_CHAINLOAD_TOOLCHAIN_FILE].
- [`CMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}`](https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_NAME.html). If `VCPKG_CMAKE_SYSTEM_NAME` is unset, defaults to `"Windows"`.
- [`CMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}`](https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_VERSION.html) if `VCPKG_CMAKE_SYSTEM_VERSION` is set.
- [`CMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON`](https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_NO_PACKAGE_REGISTRY.html)
- [`CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON`](https://cmake.org/cmake/help/latest/variable/CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY.html)
- [`CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON`](https://cmake.org/cmake/help/latest/variable/CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY.html)
- [`CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE`](https://cmake.org/cmake/help/latest/module/InstallRequiredSystemLibraries.html)
- [`CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON`](https://cmake.org/cmake/help/latest/variable/CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION.html)
- [`CMAKE_INSTALL_LIBDIR:STRING=lib`](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)
- [`CMAKE_INSTALL_BINDIR:STRING=bin`](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)

This command also passes all options in [`VCPKG_CMAKE_CONFIGURE_OPTIONS`](../users/triplets.md#vcpkg_cmake_configure_options) and the configuration-specific options from `VCPKG_CMAKE_CONFIGURE_OPTIONS_RELEASE` or `VCPKG_CMAKE_CONFIGURE_OPTIONS_DEBUG`.

Finally, there are additional internal options passed in (with a `VCPKG_` prefix) that should not be depended upon.

## Examples

```cmake
vcpkg_from_github(OUT_SOURCE_PATH source_path ...)
vcpkg_cmake_configure(
    SOURCE_PATH "${source_path}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)
vcpkg_cmake_install()
```

[Search microsoft/vcpkg for Examples](https://github.com/microsoft/vcpkg/search?q=vcpkg_cmake_configure+path%3A%2Fports)

## Remarks

This command replaces [`vcpkg_configure_cmake()`](vcpkg_configure_cmake.md).

## Source
[ports/vcpkg-cmake/vcpkg\_cmake\_configure.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-cmake/vcpkg_cmake_configure.cmake)

[ninja]: https://ninja-build.org/
[VCPKG_CHAINLOAD_TOOLCHAIN_FILE]: ../users/triplets.md#VCPKG_CHAINLOAD_TOOLCHAIN_FILE
