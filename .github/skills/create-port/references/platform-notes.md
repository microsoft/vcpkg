# Platform-Specific Considerations

## Supported Platforms

### Windows Triplets
- `x86-windows` - 32-bit Windows
- `x64-windows` - 64-bit Windows  
- `arm-windows` - ARM Windows
- `arm64-windows` - ARM64 Windows
- `x64-windows-static` - Static linking on Windows
- `x64-windows-static-md` - Static libs with dynamic CRT

### Linux Triplets
- `x64-linux` - 64-bit Linux
- `arm64-linux` - ARM64 Linux

### macOS Triplets  
- `x64-osx` - Intel-based Macs
- `arm64-osx` - Apple Silicon Macs

### Mobile Platforms
- `arm64-android` - Android ARM64
- `arm-android` - Android ARM
- `x64-android` - Android x86_64
- `x86-android` - Android x86
- `arm64-ios` - iOS ARM64
- `x64-ios` - iOS Simulator

## Platform Support Declaration

### Universal Support
Most packages work everywhere:
```json
{
  "name": "mypackage",
  "supports": "!(uwp)"
}
```

### Limited Platform Support
```json
{
  "name": "windows-only-lib", 
  "supports": "windows"
}
```

### Complex Platform Logic
```json
{
  "name": "cross-platform-lib",
  "supports": "!(uwp | xbox | arm)"
}
```

## Platform-Specific Dependencies

### Windows-Specific
```json
{
  "dependencies": [
    {
      "name": "winsock2",
      "platform": "windows"  
    },
    {
      "name": "bcrypt",
      "platform": "windows & !uwp"
    }
  ]
}
```

### Unix-Specific  
```json
{
  "dependencies": [
    {
      "name": "pthread", 
      "platform": "!windows"
    },
    {
      "name": "x11",
      "platform": "linux"
    }
  ]
}
```

## Build System Considerations

### CMake Platform Variables
```cmake
if(WIN32)
    # Windows-specific configuration
    target_compile_definitions(${TARGET} PRIVATE PLATFORM_WINDOWS=1)
    target_link_libraries(${TARGET} PRIVATE ws2_32 advapi32)
elseif(APPLE)
    # macOS-specific configuration  
    target_compile_definitions(${TARGET} PRIVATE PLATFORM_MACOS=1)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    target_link_libraries(${TARGET} PRIVATE ${COREFOUNDATION_LIBRARY})
elseif(UNIX)
    # Linux-specific configuration
    target_compile_definitions(${TARGET} PRIVATE PLATFORM_LINUX=1)
    target_link_libraries(${TARGET} PRIVATE pthread dl)
endif()
```

### Compiler-Specific Handling
```cmake
if(MSVC)
    # MSVC-specific flags
    target_compile_options(${TARGET} PRIVATE /W4 /WX)
    target_compile_definitions(${TARGET} PRIVATE _CRT_SECURE_NO_WARNINGS)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # GCC/Clang flags
    target_compile_options(${TARGET} PRIVATE -Wall -Wextra -Werror)
endif()
```

## Static vs Shared Libraries

### Windows Considerations
```cmake
# Handle Windows DLL exports
if(WIN32 AND BUILD_SHARED_LIBS)
    target_compile_definitions(${TARGET} PRIVATE MYLIB_EXPORTS)
    target_compile_definitions(${TARGET} INTERFACE MYLIB_IMPORTS) 
endif()
```

### Symbol Visibility on Unix
```cmake
if(UNIX AND BUILD_SHARED_LIBS)
    target_compile_options(${TARGET} PRIVATE -fvisibility=hidden)
    target_compile_definitions(${TARGET} PRIVATE MYLIB_VISIBILITY=__attribute__((visibility("default"))))
endif()
```

## Mobile Platform Specifics

### Android Considerations
```json
{
  "name": "android-lib",
  "supports": "android",
  "dependencies": [
    {
      "name": "android-ndk",
      "host": true
    }
  ]
}
```

### iOS Considerations  
```json
{
  "name": "ios-lib", 
  "supports": "ios",
  "dependencies": [
    {
      "name": "ios-frameworks",
      "platform": "ios"
    }
  ]
}
```

## Architecture-Specific Issues

### ARM Considerations
Some packages have ARM-specific build requirements:
```cmake
if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm" OR CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
    # ARM-specific optimizations or workarounds
    target_compile_definitions(${TARGET} PRIVATE ARM_OPTIMIZATIONS=1)
endif()
```

### x86 vs x64 Differences
```cmake
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    # 64-bit specific code
    target_compile_definitions(${TARGET} PRIVATE ARCH_64BIT=1)
else()
    # 32-bit specific code  
    target_compile_definitions(${TARGET} PRIVATE ARCH_32BIT=1)
endif()
```

## Common Platform Issues

### Windows-Specific
1. **Path Length Limits**: Use short build paths
2. **DLL Export/Import**: Handle `__declspec(dllexport/dllimport)` 
3. **Runtime Library**: Ensure CRT compatibility
4. **Unicode**: Handle wide character strings properly

### Linux-Specific  
1. **Shared Library Versioning**: Use SONAME correctly
2. **Dependency Resolution**: Handle system package differences
3. **Compiler Variations**: Test with GCC and Clang
4. **Distribution Differences**: Ubuntu vs CentOS vs Alpine

### macOS-Specific
1. **Framework Linking**: Use proper framework search paths  
2. **Code Signing**: Handle entitlements for some features
3. **Universal Binaries**: Support both Intel and Apple Silicon
4. **SDK Versions**: Handle minimum deployment target

## Testing Across Platforms

### Continuous Integration Setup
```yaml
# Example CI matrix testing
strategy:
  matrix:
    include:
      - os: windows-latest
        triplet: x64-windows
      - os: windows-latest  
        triplet: x64-windows-static
      - os: ubuntu-latest
        triplet: x64-linux
      - os: macos-latest
        triplet: x64-osx
      - os: macos-latest
        triplet: arm64-osx
```

### Local Testing Commands
```powershell
# Test major platforms locally
vcpkg install mypackage:x64-windows
vcpkg install mypackage:x64-windows-static  
vcpkg install mypackage:x64-linux
vcpkg install mypackage:x64-osx

# Test mobile platforms if supported
vcpkg install mypackage:arm64-android
vcpkg install mypackage:arm64-ios
```

## Best Practices

1. **Test on all target platforms** before submitting
2. **Use platform-agnostic APIs** when possible
3. **Handle platform differences gracefully** with feature detection
4. **Document platform-specific requirements** in usage files
5. **Provide meaningful error messages** for unsupported platforms
6. **Use vcpkg platform expressions** for conditional dependencies
7. **Consider cross-compilation scenarios** for embedded targets