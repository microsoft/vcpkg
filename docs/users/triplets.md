# Triplet files

Triplet is a standard term used in cross compiling as a way to completely capture the target environment (cpu, os, compiler, runtime, etc) in a single convenient name.

In Vcpkg, we use triplets to describe self-consistent builds of library sets. This means every library will be built using the same target cpu, OS, and compiler toolchain, but also CRT linkage and preferred library type.

We currently provide many triplets by default (run `vcpkg help triplet`). However, you can easily add your own by creating a new file in the `triplets\` directory. The new triplet will immediately be available for use in commands, such as `vcpkg install boost:x86-windows-custom`.

To change the triplet used by your project, such as to enable static linking, see our [Integration Document](integration.md#triplet-selection).

## Variables
### VCPKG_TARGET_ARCHITECTURE
Specifies the target machine architecture.

Valid options are `x86`, `x64`, and `arm`.

### VCPKG_CRT_LINKAGE
Specifies the desired MSVCRT linkage.

Valid options are `dynamic` and `static`.

### VCPKG_LIBRARY_LINKAGE
Specifies the preferred library linkage.

Valid options are `dynamic` and `static`. Note that libraries can ignore this setting if they do not support the preferred linkage type.

### VCPKG_CMAKE_SYSTEM_NAME
Specifies the target platform.

Valid options are `WindowsStore` or empty. Empty corresponds to Windows Desktop and `WindowsStore` corresponds to UWP.
When setting this variable to `WindowsStore`, you must also set `VCPKG_CMAKE_SYSTEM_VERSION` to `10.0`.

### VCPKG_PLATFORM_TOOLSET
Specifies the C/C++ compiler toolchain to use.

This can be set to `v141`, `v140`, or left blank. If left blank, we select the latest compiler toolset available on your machine.

Visual Studio 2015 platform toolset is `v140`  
Visual Studio 2017 platform toolset is `v141`

## Per-port customization
The CMake Macro `PORT` will be set when interpreting the triplet file and can be used to change settings (such as `VCPKG_LIBRARY_LINKAGE`) on a per-port basis.

Example:
```cmake
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CRT_LINKAGE dynamic)
if(PORT MATCHES "qt5-")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
```
This will build all the `qt5-*` libraries as DLLs against the dynamic CRT, but every other library as a static library (still against the dynamic CRT).

For an example in a real project, see https://github.com/Intelight/vcpkg/blob/master/triplets/x86-windows-mixed.cmake.

## Additional Remarks
The default triplet when running any vcpkg command is `%VCPKG_DEFAULT_TRIPLET%` or `x86-windows` if that environment variable is undefined.

We recommend using a systematic naming scheme when creating new triplets. The Android toolchain naming scheme is a good source of inspiration: https://developer.android.com/ndk/guides/standalone_toolchain.html.
