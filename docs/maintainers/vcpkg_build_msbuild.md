# vcpkg_build_msbuild

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_build_msbuild.md).

Build a msbuild-based project. Deprecated in favor of `vcpkg_install_msbuild()`.

## Usage
```cmake
vcpkg_build_msbuild(
    PROJECT_PATH <${SOURCE_PATH}/port.sln>
    [RELEASE_CONFIGURATION <Release>]
    [DEBUG_CONFIGURATION <Debug>]
    [TARGET <Build>]
    [TARGET_PLATFORM_VERSION <10.0.15063.0>]
    [PLATFORM <${TRIPLET_SYSTEM_ARCH}>]
    [PLATFORM_TOOLSET <${VCPKG_PLATFORM_TOOLSET}>]
    [OPTIONS </p:ZLIB_INCLUDE_PATH=X>...]
    [OPTIONS_RELEASE </p:ZLIB_LIB=X>...]
    [OPTIONS_DEBUG </p:ZLIB_LIB=X>...]
    [USE_VCPKG_INTEGRATION]
)
```

## Parameters
### USE_VCPKG_INTEGRATION
Apply the normal `integrate install` integration for building the project.

By default, projects built with this command will not automatically link libraries or have header paths set.

### PROJECT_PATH
The path to the solution (`.sln`) or project (`.vcxproj`) file.

### RELEASE_CONFIGURATION
The configuration (``/p:Configuration`` msbuild parameter) used for Release builds.

### DEBUG_CONFIGURATION
The configuration (``/p:Configuration`` msbuild parameter)
used for Debug builds.

### TARGET_PLATFORM_VERSION
The WindowsTargetPlatformVersion (``/p:WindowsTargetPlatformVersion`` msbuild parameter)

### TARGET
The MSBuild target to build. (``/t:<TARGET>``)

### PLATFORM
The platform (``/p:Platform`` msbuild parameter) used for the build.

### PLATFORM_TOOLSET
The platform toolset (``/p:PlatformToolset`` msbuild parameter) used for the build.

### OPTIONS
Additional options passed to msbuild for all builds.

### OPTIONS_RELEASE
Additional options passed to msbuild for Release builds. These are in addition to `OPTIONS`.

### OPTIONS_DEBUG
Additional options passed to msbuild for Debug builds. These are in addition to `OPTIONS`.

## Examples

* [chakracore](https://github.com/Microsoft/vcpkg/blob/master/ports/chakracore/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_build\_msbuild.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_build_msbuild.cmake)
