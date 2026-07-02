# CMake Integration Patterns

## Modern CMake Targets

### Standard Pattern
```cmake
find_package(PackageName CONFIG REQUIRED)
target_link_libraries(main PRIVATE PackageName::PackageName)
```

### Namespaced Targets
Popular packages often use namespace prefixes:
```cmake
# Boost libraries
target_link_libraries(main PRIVATE Boost::system Boost::filesystem)

# Google libraries  
target_link_libraries(main PRIVATE glog::glog)
target_link_libraries(main PRIVATE gtest::gtest gtest::main)

# Microsoft libraries
target_link_libraries(main PRIVATE Microsoft.GSL::GSL)
```

### Header-Only Libraries
```cmake
find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(main PRIVATE nlohmann_json::nlohmann_json)

# Alternative for header-only
target_include_directories(main PRIVATE ${nlohmann_json_INCLUDE_DIRS})
```

## Component-Based Packages

### Qt Components
```cmake
find_package(Qt6 CONFIG REQUIRED COMPONENTS Core Widgets Network)
target_link_libraries(main PRIVATE Qt6::Core Qt6::Widgets Qt6::Network)
```

### Boost Components
```cmake
find_package(Boost CONFIG REQUIRED COMPONENTS system filesystem thread)
target_link_libraries(main PRIVATE Boost::system Boost::filesystem Boost::thread)
```

### OpenCV Components
```cmake
find_package(OpenCV CONFIG REQUIRED COMPONENTS core imgproc imgcodecs)
target_link_libraries(main PRIVATE opencv::opencv)
```

## Compatibility Patterns

### Legacy and Modern Support
```cmake
# Try modern CMake config first
find_package(PackageName CONFIG QUIET)
if(NOT PackageName_FOUND)
    # Fallback to FindModule
    find_package(PackageName MODULE REQUIRED)
    # Create modern target from legacy variables
    add_library(PackageName::PackageName INTERFACE IMPORTED)
    set_target_properties(PackageName::PackageName PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${PackageName_INCLUDE_DIRS}"
        INTERFACE_LINK_LIBRARIES "${PackageName_LIBRARIES}"
    )
endif()
```

### Unofficial Namespace
For packages that don't provide proper CMake configs (required by vcpkg guidelines):
```cmake
find_package(unofficial-sqlite3 CONFIG REQUIRED)
target_link_libraries(main PRIVATE unofficial::sqlite3)
```

### vcpkg-Created Targets
All targets created by vcpkg ports must use the unofficial namespace:
```cmake
# Correct - vcpkg port creates unofficial target
find_package(mylib CONFIG REQUIRED)
target_link_libraries(main PRIVATE unofficial::mylib)

# Avoid - don't create targets that might conflict with upstream
# target_link_libraries(main PRIVATE mylib::mylib)
```

## Platform-Specific Integration

### Windows-Only Features
```cmake
if(WIN32)
    find_package(WindowsSDK CONFIG REQUIRED)
    target_link_libraries(main PRIVATE WindowsSDK::d3d11)
endif()
```

### Unix-Only Libraries
```cmake
if(UNIX)
    find_package(X11 REQUIRED)
    target_link_libraries(main PRIVATE ${X11_LIBRARIES})
endif()
```

## Feature Flags in Usage

### Optional Components
```cmake
# Basic usage
find_package(PackageName CONFIG REQUIRED)
target_link_libraries(main PRIVATE PackageName::core)

# With optional features
if(ENABLE_OPENSSL)
    find_package(PackageName CONFIG REQUIRED COMPONENTS ssl)
    target_link_libraries(main PRIVATE PackageName::ssl)
endif()
```

### Conditional Features
```cmake
# Check what features are available
find_package(PackageName CONFIG REQUIRED)
if(TARGET PackageName::networking)
    target_link_libraries(main PRIVATE PackageName::networking)
    target_compile_definitions(main PRIVATE HAS_NETWORKING=1)
endif()
```

## Best Practices for Usage Files

1. **Usage files are optional** - vcpkg generates heuristic usage when find_package() is available
2. **Only create usage files when heuristics are incorrect** - Don't create them by default
3. **Show working minimal examples** that users can copy-paste
4. **Show both REQUIRED and COMPONENTS usage** when applicable  
5. **Include conditional examples** for optional features
6. **Use modern target syntax** (`target_link_libraries` with targets)
7. **Document any special setup** required beyond `find_package()`
8. **Include pkg-config alternatives** when available
9. **Show debug/release specific usage** if needed
10. **Never include #include statements in usage files** - That's application code, not integration guidance

## Common Antipatterns to Avoid

❌ **Using legacy variables:**
```cmake
find_package(PackageName CONFIG REQUIRED)
include_directories(${PackageName_INCLUDE_DIRS})
link_libraries(${PackageName_LIBRARIES})
```

❌ **Hardcoded paths:**
```cmake
target_include_directories(main PRIVATE "C:/vcpkg/installed/x64-windows/include")
```

✅ **Use modern targets:**
```cmake
find_package(PackageName CONFIG REQUIRED)
target_link_libraries(main PRIVATE PackageName::PackageName)
```
