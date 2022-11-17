# vcpkg_xcode_build

**The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_xcode_build.md).**

Build a XCode project with a custom install target.

Ports should prefer calling [`vcpkg_xcode_install()`](vcpkg_xcode_install.md) when possible.

## Usage

```cmake
vcpkg_xcode_build(
    [SOURCE_PATH <source>]
    [PROJECT_FILE <xcode_file>]
    [TARGET <target>]
    [SCHEME <scheme>]
    [LOGFILE_BASE <base>]
    [DISABLE_PARALLEL]
)
```

To use this function, you must depend on the helper port [`vcpkg-xcode`](ports/vcpkg-xcode.md):
```no-highlight
"dependencies": [
  {
    "name": "vcpkg-xcode",
    "host": true
  }
]
```

## Parameters

All supported parameters to [`vcpkg_xcode_install()`] are supported by `vcpkg_xcode_build()`. See [`vcpkg_xcode_install()`] for additional parameter documentation.

[`vcpkg_xcode_install()`]: vcpkg_xcode_install.md#parameters

### SOURCE_PATH
Specifies the directory containing the XCode project file `*.xcodeproj`.
By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.

### PROJECT_FILE
The XCode project file name that contains suffix.
This value is set as the source folder name by default.

### TARGET
The XCode target to build.
This value is set as `-alltargets` by default.

### SCHEME
The scheme to build this project.
Note: TARGET and SCHEME can't be declared both.

### DISABLE_PARALLEL
Disables running the build in parallel.

By default builds are run with up to [VCPKG_MAX_CONCURRENCY](../users/config-environment.md#VCPKG_MAX_CONCURRENCY) jobs. This option limits the build to a single job and should be used only if the underlying build is unable to run correctly with concurrency.

### LOGFILE_BASE
An alternate root name for the logs.

Defaults to `build-${TARGET_TRIPLET}`. It should not contain any path separators. Logs will be generated matching the pattern `${CURRENT_BUILDTREES_DIR}/${LOGFILE_BASE}-<suffix>.log`

## Examples

```cmake
vcpkg_from_github(OUT_SOURCE_PATH source_path ...)
vcpkg_xcode_build(SOURCE_PATH ${source_path} PROJECT_FILE my_project.xcodeproj)
```

[Search microsoft/vcpkg for Examples](https://github.com/microsoft/vcpkg/search?q=vcpkg_xcode_build+path%3A%2Fports)

## Source
[ports/vcpkg-xcode/vcpkg\_xcode\_build.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-xcode/vvcpkg_xcode_build.cmake)
