# Dependency Management Guide

## Dependency Types in vcpkg.json

### Regular Dependencies
Runtime dependencies required by the package:
```json
{
  "dependencies": [
    "zlib",
    "openssl",
    "boost-system"
  ]
}
```

### Host Dependencies  
Build-time tools that run on the host machine:
```json
{
  "dependencies": [
    {
      "name": "vcpkg-cmake", 
      "host": true
    },
    {
      "name": "vcpkg-cmake-config",
      "host": true  
    }
  ]
}
```

### Platform-Specific Dependencies
Dependencies that only apply to certain platforms:
```json
{
  "dependencies": [
    {
      "name": "pthread",
      "platform": "!windows"
    },
    {
      "name": "winsock2", 
      "platform": "windows"
    }
  ]
}
```

### Feature Dependencies
Dependencies that are only needed for specific features:
```json
{
  "features": {
    "ssl": {
      "description": "Enable SSL support",
      "dependencies": ["openssl"]
    },
    "compression": {
      "description": "Enable compression",
      "dependencies": ["zlib", "bzip2"]
    }
  }
}
```

## Common vcpkg Dependencies

### CMake Integration
Almost all CMake-based ports need:
```json
{
  "dependencies": [
    {
      "name": "vcpkg-cmake",
      "host": true
    },
    {
      "name": "vcpkg-cmake-config", 
      "host": true
    }
  ]
}
```

### Common Libraries
Frequently used dependencies:
```json
{
  "dependencies": [
    "zlib",          // Compression
    "openssl",       // Cryptography
    "boost",         // C++ libraries
    "fmt",           // String formatting  
    "spdlog",        // Logging
    "nlohmann-json", // JSON parsing
    "catch2",        // Testing (test feature)
    "benchmark"      // Benchmarking (benchmark feature)
  ]
}
```

## Version Requirements

### Minimum Version Constraints
```json
{
  "dependencies": [
    {
      "name": "boost",
      "version>=": "1.75.0"
    }
  ]
}
```

### Exact Version Requirements  
```json
{
  "dependencies": [
    {
      "name": "protobuf",
      "version": "3.21.12"
    }
  ]
}
```

## Dependency Resolution Best Practices

### 1. Minimize Dependencies
Only include dependencies that are truly required:
```json
// Good - minimal dependencies
{
  "dependencies": ["zlib"]
}

// Bad - unnecessary dependencies
{
  "dependencies": ["zlib", "boost", "qt5", "opencv"]
}
```

### 2. Use Feature Flags for Optional Dependencies
```json
{
  "dependencies": ["zlib"],
  "features": {
    "ssl": {
      "description": "Enable SSL support", 
      "dependencies": ["openssl"]
    },
    "gui": {
      "description": "Enable GUI components",
      "dependencies": ["qt5-base", "qt5-widgets"]
    }
  }
}
```

### 3. Platform-Specific Handling
```json
{
  "dependencies": [
    {
      "name": "pthread",
      "platform": "linux | osx"
    },
    {
      "name": "ws2_32",
      "platform": "windows & static"
    }
  ]
}
```

## Circular Dependency Prevention

### Problem: Circular Dependencies
```
Package A depends on Package B
Package B depends on Package A
```

### Solutions:

1. **Extract Common Functionality**
   Create a third package with shared code

2. **Use Optional Dependencies**
   Make one direction optional via features

3. **Interface Segregation**
   Split packages into smaller, focused components

## Testing Dependencies

### Development Dependencies
Dependencies only needed for building/testing:
```json
{
  "features": {
    "test": {
      "description": "Build tests",
      "dependencies": [
        "catch2",
        "gtest"
      ]
    }
  }
}
```

### Example Integration
Never include test frameworks in default dependencies:
```json
// Good
{
  "dependencies": ["zlib"],
  "features": {
    "test": {
      "dependencies": ["catch2"]
    }
  }
}

// Bad  
{
  "dependencies": ["zlib", "catch2"]
}
```

## Advanced Dependency Patterns

### Transitive Dependency Override
When you need a specific version of a transitive dependency:
```json
{
  "overrides": [
    {
      "name": "zlib",
      "version": "1.2.11"  
    }
  ]
}
```

### Alternative Dependencies
For packages that can use different backends:
```json
{
  "features": {
    "backend-openssl": {
      "description": "Use OpenSSL backend",
      "dependencies": ["openssl"]
    },
    "backend-mbedtls": {
      "description": "Use mbedTLS backend", 
      "dependencies": ["mbedtls"]
    }
  }
}
```

## Validation Commands

Test dependency resolution:
```powershell
# Test default dependencies
vcpkg install package-name

# Test with features
vcpkg install package-name[ssl,compression]

# Check dependency tree
vcpkg depend-info package-name

# Verify all triplets work
vcpkg install package-name:x64-windows
vcpkg install package-name:x64-linux
```

## Common Dependency Issues

### 1. Missing Host Dependencies
**Problem**: CMake configuration fails
**Solution**: Add vcpkg-cmake and vcpkg-cmake-config as host dependencies

### 2. Version Conflicts
**Problem**: Multiple packages require different versions
**Solution**: Use version constraints or overrides

### 3. Platform Incompatibility
**Problem**: Dependencies don't work on all platforms
**Solution**: Use platform-specific dependency declarations

### 4. Feature Bleeding
**Problem**: Optional features pull in too many dependencies
**Solution**: Make features more granular, use default-features sparingly
