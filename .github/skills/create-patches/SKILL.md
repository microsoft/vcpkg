---
name: create-patches
description: 'Create and manage patches for vcpkg ports. Use for fixing build issues, adding compatibility modifications, and managing source code changes required for vcpkg integration.'
argument-hint: 'Port name, or: --build-dir <path-to-buildtrees/port> --port-dir <path-to-ports/port> for analyzing build failures'
---

# vcpkg Patch Generator

## When to Use

- **Fixing build failures**: Analyze build errors from failed vcpkg installations and create patches
- **Build system incompatibilities**: Fix build issues for vcpkg compatibility
- **Adding missing CMake exports**: Export targets for proper vcpkg integration
- **Platform-specific fixes**: Add Windows/macOS/Linux compatibility modifications
- **Dependency management**: Replace vendored dependencies with vcpkg packages
- **Installation corrections**: Fix header paths, library installation, and file organization
- **Existing port maintenance**: Update patches for version upgrades or new issues

## Usage Modes

### Mode 1: Build Failure Analysis (Recommended)
**Arguments:**
- `--build-dir <path>`: Path to failed build directory (e.g., `buildtrees/package-name/`)
- `--port-dir <path>`: Path to corresponding port directory (e.g., `ports/package-name/`)

**Example:**
```
create-patches --build-dir buildtrees/mylibrary --port-dir ports/mylibrary
```

This mode analyzes build logs, examines extracted source code, identifies common issues, and guides you through creating appropriate patches.

### Mode 2: Port Name (Simple)
For general patch creation when you know the port name:
```
create-patches mylibrary
```

## Patch Requirements

Patches must be implemented using the `PATCHES` parameter with `vcpkg_from_github()`:

**Key Rules:**
- **Use PATCHES parameter only** - Never modify source code directly in portfile.cmake
- **Minimal changes** - Only modify what's necessary for vcpkg compatibility
- **Test across platforms** - Ensure patches work on Windows, macOS, and Linux
- **Version independence** - Write patches that work across minor version updates when possible

## Build Failure Analysis Workflow

### Prerequisites
1. **Failed vcpkg installation** that needs fixing
2. **Build directory** preserved (in `buildtrees/package-name/`)
3. **Port directory** with current portfile (in `ports/package-name/`)

### Directory Structures
**Build Directory:**
```
buildtrees/package-name/
├── src/                    # Extracted source code
│   └── commit-hash/        # Source at specific commit
├── build-triplet/          # Build attempt outputs
│   ├── CMakeCache.txt      # CMake configuration
│   ├── config.log          # Build system logs  
│   └── *.log              # Detailed build logs
└── vcpkg-*.log            # vcpkg-specific logs
```

**Port Directory:**
```
ports/package-name/
├── vcpkg.json             # Current manifest
├── portfile.cmake         # Current build script
├── usage                  # Usage documentation
└── patches/               # Existing patches (if any)
```

### Analysis Process

**Step 1: Build Log Analysis**
The skill examines build logs to identify common failure patterns:
- **CMake Configuration**: Missing dependencies, export target issues, installation path problems
- **Compilation**: Missing headers, Windows DLL export issues, platform-specific compiler errors
- **Link-time**: Missing libraries, symbol resolution issues
- **Installation**: File not found during install, permission or path issues

**Step 2: Source Code Analysis**
Examines the extracted source code for:
- Build system detection (CMake, Makefiles, custom systems)
- Missing CMake target exports
- Incorrect installation paths
- Vendored dependencies that need replacement
- Platform-specific compatibility problems

**Step 3: Guided Patch Creation**
Provides specific patch recommendations with:
- Automatic issue detection
- Interactive patch generation
- Exact code changes needed
- Generated patch files
- Updated portfile.cmake configuration

### Example Analysis Session

**Input:**
```bash
create-patches --build-dir buildtrees/rapidjson --port-dir ports/rapidjson
```

**Output:**
```
🔍 Analyzing build failure...

BUILD DIRECTORY: buildtrees/rapidjson/
- Source extracted to: buildtrees/rapidjson/src/v1.1.0-973dc9a06d/
- Build attempted in: buildtrees/rapidjson/x64-windows/

PORT DIRECTORY: ports/rapidjson/
- Manifest: vcpkg.json ✓, Portfile: portfile.cmake ✓, Usage: usage ✓

🔴 ISSUES IDENTIFIED:
1. CMake Export Missing - No install(EXPORT) commands found
2. Header Installation Path - Headers installed to wrong path

📋 PATCH RECOMMENDATIONS:
Creating: patches/001-add-cmake-exports.patch
Creating: patches/002-fix-header-paths.patch

⚙️ NEXT STEPS:
1. Apply patches to portfile.cmake
2. Test with: vcpkg install rapidjson --debug
3. Verify CMake integration works
```

## Manual Patch Creation Workflow

### Method 1: Using Build Directory Sources (After Failed Build)

If you have a failed build available, work directly with the extracted source:

```bash
# Navigate to extracted source in buildtrees
cd buildtrees/package-name/src/commit-hash/

# Initialize git and commit original state
git init && git add . && git commit -m "Original source"

# Make your modifications, then generate patches
git add . && git commit -m "Fix for vcpkg compatibility"
git format-patch HEAD~1 --output-directory ../../../ports/package-name/patches/
```

### Method 2: Using Fresh Clone (Traditional Method)

**Step 1: Create Local Clone**
```bash
git clone https://github.com/owner/repo.git
cd repo
git checkout <commit-hash>  # Use same commit as portfile REF parameter
```

**Step 2: Make Required Changes**
Make changes to fix vcpkg compatibility issues:
- CMake fixes (export missing targets, fix installation paths)
- Build system issues (missing compiler flags or dependencies)  
- Include path corrections
- Platform compatibility fixes
- Dependency detection fixes
- Remove vendored dependencies

**Step 3: Generate Patch Files**
```bash
# Single patch
git add . && git commit -m "Fix for vcpkg compatibility"
git format-patch HEAD~1 --output-directory ../patches

# Multiple logical changes
git add file1.cmake && git commit -m "Fix CMake exports"
git add file2.cpp && git commit -m "Add Windows compatibility"
git format-patch HEAD~2 --output-directory ../patches
```

**Step 4: Organize and Apply Patches**
```bash
# Place in port directory structure
ports/package-name/patches/
├── 001-fix-cmake-exports.patch
├── 002-fix-installation-paths.patch
└── 003-add-windows-support.patch

# Apply in portfile.cmake
PATCHES
    patches/001-fix-cmake-exports.patch
    patches/002-fix-installation-paths.patch
    patches/003-add-windows-support.patch
```

## Common Patch Patterns & Best Practices

### Content Guidelines
- **Focus on vcpkg Compatibility**: Only modify what's necessary for vcpkg integration
- **Clear Documentation**: Use descriptive commit messages and add comments explaining fixes
- **Maintain Compatibility**: Test on Windows, macOS, and Linux; verify Debug and Release configurations

### Pattern Library

**1. CMake Export Fixes:**
```cmake
install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Config.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION lib/cmake/${PROJECT_NAME}
)
```

**2. Include Path Corrections:**
```cmake
install(DIRECTORY include/ 
    DESTINATION include/${PROJECT_NAME}
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)
```

**3. Platform-Specific Fixes:**
```cpp
#ifdef _WIN32
    #ifdef BUILDING_DLL
        #define API_EXPORT __declspec(dllexport)
    #else
        #define API_EXPORT __declspec(dllimport)
    #endif
#else
    #define API_EXPORT
#endif
```

**4. Dependency Detection Fixes:**
```cmake
find_package(OpenSSL REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE OpenSSL::SSL OpenSSL::Crypto)
```

**5. Remove Vendored Dependencies:**
```cmake
# Replace: add_subdirectory(vendor/json)
# With:
find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(mylib PRIVATE nlohmann_json::nlohmann_json)
```

### Testing Patches
```bash
# Local testing
cd source-directory
git apply ../ports/package-name/patches/001-fix-build.patch

# vcpkg testing
vcpkg install package-name
vcpkg install package-name:x64-windows
vcpkg install package-name:x64-linux
```

## Example Workflows

### Scenario 1: Fixing Failed vcpkg Install (CMake Export Errors)

**Build Analysis Approach:**
```bash
create-patches --build-dir buildtrees/mypackage --port-dir ports/mypackage
```
→ Analysis detects missing CMake exports, auto-generates patch, updates portfile.cmake

**Manual Approach:**
```bash
cd buildtrees/mypackage/src/v1.2.3-abc123/
git init && git add . && git commit -m "Original source"

# Add missing CMake exports to CMakeLists.txt
install(TARGETS mypackage
    EXPORT mypackageTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

git add . && git commit -m "Add CMake exports"
git format-patch HEAD~1 --output-directory=../../../../ports/mypackage/patches/
```

### Scenario 2: Windows DLL Export Issues

**Build Analysis:** Detects missing DLL exports, generates platform-conditional patches automatically

**Manual Fix:**
```cpp
// Add to main header
#ifdef _WIN32
    #ifdef BUILDING_MYLIB
        #define MYLIB_API __declspec(dllexport)
    #else  
        #define MYLIB_API __declspec(dllimport)
    #endif
#else
    #define MYLIB_API
#endif

// Apply to public functions
MYLIB_API void public_function();
```

### Scenario 3: Remove Vendored Dependencies

**Build Analysis:** Detects embedded libraries, identifies vcpkg alternatives, generates replacement patches

**Manual Process:** Remove vendored directories, update build system to use `find_package()`, update vcpkg.json dependencies

## Method Comparison

**Use Build Analysis When:**
- vcpkg install has failed and buildtrees/ is available
- Want automated issue detection and patch generation
- Need quick fixes for existing port maintenance

**Use Manual Clone When:**
- Creating patches for new ports before any build
- Working on comprehensive upstream contributions
- Need broader source code context understanding

## Maintaining Patches

### Version Updates
When updating library versions:
1. **Test patch application:** Clone new version and apply existing patches
2. **Update if needed:** Resolve conflicts, regenerate patches with updated line numbers
3. **Consider upstream:** Submit patches upstream to reduce maintenance burden

### Documentation Standards
**In portfile.cmake comments:**
```cmake
# Apply patches for vcpkg compatibility:
# - 001-fix-cmake-exports.patch: Add missing CMake target exports
# - 002-windows-dll-fix.patch: Fix Windows DLL symbol exports  
PATCHES
    patches/001-fix-cmake-exports.patch
    patches/002-windows-dll-fix.patch  
```

**In patch commit messages:**
```
Fix CMake target exports for vcpkg compatibility

- Add install(EXPORT) commands for mylibTargets
- Export targets to lib/cmake/mylib/mylibConfig.cmake
- Use mylib:: namespace for exported targets
- Required for proper vcpkg CMake integration
```

## Validation and Testing

### Post-Analysis Testing
After creating patches using build failure analysis:
```bash
# Test fixed build
vcpkg install package-name --debug

# Verify integration
# Create test CMakeLists.txt:
find_package(package-name CONFIG REQUIRED)
target_link_libraries(test PRIVATE package-name::package-name)
```

### Cross-Platform Testing
```bash
# Test all supported platforms
vcpkg install package-name:x64-windows
vcpkg install package-name:x64-linux
vcpkg install package-name:arm64-osx
```

## Summary

The create-patches skill provides two complementary approaches:

1. **Build Failure Analysis** - Automated patch creation from failed builds with immediate context and guided recommendations
2. **Manual Creation** - Traditional approach using fresh clones for comprehensive fixes and upstream contributions

Both methods ensure proper vcpkg integration through the PATCHES parameter while maintaining platform compatibility and following best practices for patch organization and testing.