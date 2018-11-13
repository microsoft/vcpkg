# Triplet files

Triplet is a standard term used in cross compiling as a way to completely capture the target environment (cpu, os, compiler, runtime, etc) in a single convenient name.

In Vcpkg, we use triplets to describe self-consistent builds of library sets. This means every library will be built using the same target cpu, OS, and compiler toolchain, but also CRT linkage and preferred library type.

We currently provide many triplets by default (run `vcpkg help triplet`). However, you can easily add your own by creating a new file in the `triplets\` directory. The new triplet will immediately be available for use in commands, such as `vcpkg install boost:x86-windows-custom`.

To change the triplet used by your project, such as to enable static linking, see our [Integration Document](integration.md#triplet-selection).

## Variables
### VCPKG_TARGET_ARCHITECTURE
Specifies the target machine architecture.

Valid options are `x86`, `x64`, `arm`, and `arm64`.

### VCPKG_CRT_LINKAGE
Specifies the desired CRT linkage (for MSVC).

Valid options are `dynamic` and `static`.

### VCPKG_LIBRARY_LINKAGE
Specifies the preferred library linkage.

Valid options are `dynamic` and `static`. Note that libraries can ignore this setting if they do not support the preferred linkage type.

### VCPKG_CMAKE_SYSTEM_NAME
Specifies the target platform.

Valid options include any CMake system name, such as:
- Empty (Windows Desktop for legacy reasons)
- `WindowsStore` (Universal Windows Platform)
- `Darwin` (Mac OSX)
- `Linux` (Linux)

### VCPKG_PLATFORM_TOOLSET
Specifies the VS-based C/C++ compiler toolchain to use.

This can be set to `v141`, `v140`, or left blank. If left blank, we select the latest compiler toolset available on your machine.

Visual Studio 2015 platform toolset is `v140`  
Visual Studio 2017 platform toolset is `v141`

### VCPKG_VISUAL_STUDIO_PATH
Specifies the Visual Studio installation to use.

When unspecified, a Visual Studio instance is selected automatically, preferring Stable 2017, then Preview 2017, then 2015.

The path should be absolute, formatted with backslashes, and have no trailing slash:
```cmake
set(VCPKG_VISUAL_STUDIO_PATH "C:\\Program Files (x86)\\Microsoft Visual Studio\\Preview\\Community")
```

### VCPKG_CHAINLOAD_TOOLCHAIN_FILE
Specifies an alternate CMake Toolchain file to use.

This (if set) will override all other compiler detection logic. By default, a toolchain file is selected from `scripts/toolchains/` appropriate to the platform.

See also the CMake documentation for toolchain files: https://cmake.org/cmake/help/v3.11/manual/cmake-toolchains.7.html.

### VCPKG_CXX_FLAGS
Sets additional compiler flags to be used when not using `VCPKG_CHAINLOAD_TOOLCHAIN_FILE`.

This option also has forms for configuration-specific and C flags:
- `VCPKG_CXX_FLAGS`
- `VCPKG_CXX_FLAGS_DEBUG`
- `VCPKG_CXX_FLAGS_RELEASE`
- `VCPKG_C_FLAGS`
- `VCPKG_C_FLAGS_DEBUG`
- `VCPKG_C_FLAGS_RELEASE`

## Per-port customization
The CMake Macro `PORT` will be set when interpreting the triplet file and can be used to change settings (such as `VCPKG_LIBRARY_LINKAGE`) on a per-port basis.

Example:
```cmake
set(VCPKG_LIBRARY_LINKAGE static)
if(PORT MATCHES "qt5-")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
```
This will build all the `qt5-*` libraries as DLLs, but every other library as a static library.

For an example in a real project, see https://github.com/Intelight/vcpkg/blob/master/triplets/x86-windows-mixed.cmake.

## Additional Remarks
The default triplet when running any vcpkg command is `%VCPKG_DEFAULT_TRIPLET%` or a platform-specific choice if that environment variable is undefined.

- Windows: `x86-windows`
- Linux: `x64-linux`
- OSX: `x64-osx`

We recommend using a systematic naming scheme when creating new triplets. The Android toolchain naming scheme is a good source of inspiration: https://developer.android.com/ndk/guides/standalone_toolchain.html.
