# CMake Integration

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/buildsystems/cmake-integration.md).**

See [Installing and Using Packages Example: sqlite](../../examples/installing-and-using-packages.md) for a fully worked example using CMake.

## Table of Contents

- [`CMAKE_TOOLCHAIN_FILE`](#cmake_toolchain_file)
- [IDE Integration](#ide-integration)
  - [Visual Studio Code (CMake Tools extension)](#visual-studio-code-cmake-tools-extension)
  - [Visual Studio](#visual-studio)
  - [CLion](#clion)
- [Using Multiple Toolchain Files](#using-multiple-toolchain-files)
- [Settings Reference](#settings-reference)

## `CMAKE_TOOLCHAIN_FILE`

Projects configured to use the vcpkg toolchain file (via the CMake setting `CMAKE_TOOLCHAIN_FILE`) can find libraries from vcpkg using the standard CMake functions: `find_package()`, `find_path()`, and `find_library()`.

```no-highlight
cmake ../my/project -DCMAKE_TOOLCHAIN_FILE=[vcpkg-root]/scripts/buildsystems/vcpkg.cmake
```

Since version 3.21, CMake will use the environment variable `CMAKE_TOOLCHAIN_FILE`[1] as the default value for `CMAKE_TOOLCHAIN_FILE`.

**cmd**
```cmd
set CMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```
**Powershell**
```powershell
$env:CMAKE_TOOLCHAIN_FILE="[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
```
**bash**
```sh
export CMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

vcpkg does not automatically add any include or links paths into your project. To use a header-only library you can use `find_path()` which will correctly work on all platforms:

```cmake
# To find and use catch2
find_path(CATCH_INCLUDE_DIR NAMES catch.hpp PATH_SUFFIXES catch2)
include_directories(${CATCH_INCLUDE_DIR})
```

[1]: https://cmake.org/cmake/help/latest/envvar/CMAKE_TOOLCHAIN_FILE.html

## IDE Integration

### Visual Studio Code (CMake Tools Extension)

Adding the following to your workspace `settings.json` will make CMake Tools automatically use vcpkg for libraries:

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

### Visual Studio

In the CMake Settings Editor, add the path to the vcpkg toolchain file under `CMake toolchain file`:

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### CLion

Open the Toolchains settings (`File > Settings` on Windows and Linux, `CLion > Preferences` on macOS), and go to the CMake settings (`Build, Execution, Deployment > CMake`). In `CMake options`, add the following line:

```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

You must add this line to each profile separately.

## Using Multiple Toolchain Files

To combine vcpkg's toolchain file with another toolchain file, you can set the cmake variable `VCPKG_CHAINLOAD_TOOLCHAIN_FILE`:

```no-highlight
cmake ../my/project \
   -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake \
   -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=../my/project/toolchain.cmake
```

Alternatively, you can include the vcpkg toolchain at the end of the primary toolchain file:

```cmake
# MyToolchain.cmake
set(CMAKE_CXX_COMPILER ...)
set(VCPKG_TARGET_TRIPLET x64-my-custom-windows-triplet)
include(/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake)
```

**Note: vcpkg does not automatically apply your toolchain's settings, such as your compiler or compilation flags, while building libraries. To change vcpkg's library settings, you must make a [custom triplet file](../triplets.md) (which can [share your toolchain](../triplets.md#VCPKG_CHAINLOAD_TOOLCHAIN_FILE))**

## Settings Reference

All vcpkg-affecting variables must be defined before the first `project()` directive, such as via the command line or `set()` statements.

### `VCPKG_TARGET_TRIPLET`

This setting controls the [triplet](../triplets.md) vcpkg will install and consume libraries from.

If unset, vcpkg will automatically detect an appropriate default triplet given the current compiler settings. If you change this CMake variable, you must delete your cache and reconfigure.

### `VCPKG_HOST_TRIPLET`

This variable controls which [triplet](../triplets.md) host dependencies will be installed for.

If unset, vcpkg will automatically detect an appropriate native triplet (x64-windows, x64-osx, x64-linux).

See also [Host Dependencies](../host-dependencies.md).

### `VCPKG_INSTALLED_DIR`

This variable sets the location where libraries will be installed and consumed from.

In manifest mode, the default is `${CMAKE_BINARY_DIR}/vcpkg_installed`.

In classic mode, the default is `${VCPKG_ROOT}/installed`.

### `VCPKG_MANIFEST_MODE`

This variable forces vcpkg to operate in either manifest mode or classic mode.

Defaults to `ON` when `VCPKG_MANIFEST_DIR` is non-empty or `${CMAKE_SOURCE_DIR}/vcpkg.json` exists.

To disable manifest mode while a `vcpkg.json` is detected, set this to `OFF`.

### `VCPKG_MANIFEST_DIR`

This variable specifies an alternate folder containing a `vcpkg.json` manifest.

Defaults to `${CMAKE_SOURCE_DIR}` if `${CMAKE_SOURCE_DIR}/vcpkg.json` exists.

### `VCPKG_MANIFEST_INSTALL`

This variable controls whether vcpkg will be automatically run to install your dependencies during your configure step.

Defaults to `ON` if `VCPKG_MANIFEST_MODE` is `ON`.

### `VCPKG_BOOTSTRAP_OPTIONS`

This variable can be set to additional command parameters to pass to `./bootstrap-vcpkg`.

In manifest mode, vcpkg will be automatically bootstrapped if the executable does not exist.

### `VCPKG_OVERLAY_TRIPLETS`

This variable can be set to a list of paths to be passed on the command line as `--overlay-triplets=...`

### `VCPKG_OVERLAY_PORTS`

This variable can be set to a list of paths to be passed on the command line as `--overlay-ports=...`

### `VCPKG_MANIFEST_FEATURES`

This variable can be set to a list of features to activate when installing from your manifest.

For example, features can be used by projects to control building with additional dependencies to enable tests or samples:

```json
{
  "name": "mylibrary",
  "version": "1.0",
  "dependencies": [ "curl" ],
  "features": {
    "samples": {
      "description": "Build Samples",
      "dependencies": [ "fltk" ]
    },
    "tests": {
      "description": "Build Tests",
      "dependencies": [ "gtest" ]
    }
  }
}
```
```cmake
# CMakeLists.txt

option(BUILD_TESTING "Build tests" OFF)
if(BUILD_TESTING)
  list(APPEND VCPKG_MANIFEST_FEATURES "tests")
endif()

option(BUILD_SAMPLES "Build samples" OFF)
if(BUILD_SAMPLES)
  list(APPEND VCPKG_MANIFEST_FEATURES "samples")
endif()

project(myapp)

# ...
```

### `VCPKG_MANIFEST_NO_DEFAULT_FEATURES`

This variable controls activation of default features in addition to those listed in `VCPKG_MANIFEST_FEATURES`. If set to `ON`, default features will not be automatically activated.

Defaults to `OFF`.

### `VCPKG_INSTALL_OPTIONS`

This variable can be set to a list of additional command line parameters to pass to the vcpkg tool during automatic installation.

### `VCPKG_PREFER_SYSTEM_LIBS`

**This feature has been deprecated. Use empty overlay ports instead.**

This variable controls whether vcpkg will append instead of prepend its paths to `CMAKE_PREFIX_PATH`, `CMAKE_LIBRARY_PATH` and `CMAKE_FIND_ROOT_PATH` so that vcpkg libraries/packages are found after toolchain/system libraries/packages.

Defaults to `OFF`.

### `VCPKG_FEATURE_FLAGS`

This variable can be set to a list of feature flags to pass to the vcpkg tool during automatic installation to opt-in to experimental behavior.

See the `--feature-flags=` command line option for more information.

### `VCPKG_TRACE_FIND_PACKAGE`

When this option is turned on, every call to `find_package` is printed.
Nested calls (e.g. via `find_dependency`) are indented according to nesting depth.
