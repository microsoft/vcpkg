---
name: create-port
description: 'Create new vcpkg ports from scratch. Use for adding new packages, creating port structure, setting up CMake integration, managing dependencies, and ensuring vcpkg compliance.'
argument-hint: 'GitHub URL (e.g., "https://github.com/owner/repo")'
---

# New Port Creator

## When to Use

- Adding a new open-source library to the vcpkg registry
- Creating a port structure with proper manifest and build files
- Ensuring compliance with vcpkg packaging standards
- Converting existing libraries to vcpkg ports

## Overview

This skill guides you through creating a complete vcpkg port from a GitHub repository URL with automatic detection and intelligent defaults:

- **GitHub Integration**: Automatic extraction of repository details, version schemes, and build systems
- **Port Structure**: Complete `vcpkg.json` manifest and `portfile.cmake` generation
- **Smart Naming**: Intelligent port naming with conflict resolution and validation
- **Build System Support**: Auto-detection and configuration for CMake, Meson, Make, Autotools, MSBuild, and GN
- **Dependency Management**: Automatic removal of vendored dependencies and vcpkg integration
- **Compliance**: Validates against vcpkg maintainer guide standards

**Streamlined Process:** Provide a GitHub URL and the skill handles the rest!

## Detailed port creation workflow

### Step 1: GitHub Repository Input

The skill will prompt for:

**Primary Input:**
- **GitHub Repository URL**: The main source repository (e.g., `https://github.com/fmtlib/fmt`)

**Auto-extracted from GitHub URL:**
- **Package name**: Derived from repository name with vcpkg naming conventions applied
- **Homepage**: The GitHub repository URL
- **Repository info**: Owner/repo for `vcpkg_from_github()` calls

**Additional Required Information:**
- **Version**: Current upstream version (e.g., `1.2.3`, `2023-04-15`) 
- **Description**: One-line summary of what the package does
- **License**: SPDX license identifier (e.g., `MIT`, `Apache-2.0`, `GPL-3.0`)

**Optional Information:**
- **Dependencies**: Other vcpkg packages this port depends on
- **Features**: Optional components that can be enabled/disabled
- **Build system**: CMake, autotools, MSBuild, custom, etc.
- **Custom port name**: Override auto-generated name if needed

### Step 2: Automatic Analysis and Validation

**Repository Analysis:**
The skill analyzes the GitHub repository to extract:
- Repository details (owner, name, default branch)
- Version scheme detection (releases vs commit dates)
- Build system identification and vcpkg helper selection
- Library type (header-only vs compiled)
- License files and SPDX identification
- Dependencies and configuration requirements

**Intelligent Port Naming:**
Follows vcpkg maintainer guide for distinctive names:
1. Convert repository name to lowercase with hyphens
2. Cross-reference with repology.org for package manager consistency
3. Validate name recognition via web search engines
4. Apply disambiguation strategy:
   - Well-established names → use simple name (e.g., `fmt`, `spdlog`)
   - Ambiguous/generic names → use `owner-repo` pattern (e.g., `nlohmann-json`)

**Build System Detection:**
Auto-detects build systems and adds appropriate vcpkg dependencies:
- **CMake** → `vcpkg-cmake`, `vcpkg-cmake-config` (host dependencies)
- **Meson** → `vcpkg-meson` (host dependency)
- **Make** → `vcpkg-make` (host dependency)
- **Autotools** → native vcpkg support
- **MSBuild** → `vcpkg-msbuild` (host dependency)
- **GN** → `vcpkg-gn` (host dependency)
- **Unsupported** → custom CMakeLists.txt generation

**Version Scheme Selection:**
- **Releases found** → `"version": "1.2.3"` (semantic versioning)
- **Date releases** → `"version-date": "2026-03-16"` 
- **No releases** → `"version-date": "YYYY-MM-DD"` (latest commit)

### Step 3: Port Structure Generation

Creates complete port directory with optimized files:
```
ports/{package-name}/
├── vcpkg.json              # Package manifest with auto-detected dependencies
├── portfile.cmake          # Build script using appropriate vcpkg helpers
├── usage                   # CMake integration guide with unofficial:: targets
└── patches/                # Source patches (if needed)
```

**Auto-Generated Dependencies:**
Based on detected build system, automatically adds required host dependencies:
- All ports: `vcpkg-cmake`, `vcpkg-cmake-config`
- Meson projects: `vcpkg-meson`
- Make projects: `vcpkg-make` 
- MSBuild projects: `vcpkg-msbuild`
- GN projects: `vcpkg-gn`

## Generated File Templates

**vcpkg.json** - Package manifest with auto-detected metadata:
```json
{
  "name": "package-name",
  "version-date": "2026-03-16",
  "description": "Auto-extracted description",
  "homepage": "https://github.com/owner/repo", 
  "license": "MIT",
  "dependencies": [
    {"name": "vcpkg-cmake", "host": true},
    {"name": "vcpkg-cmake-config", "host": true}
  ],
  "features": {
    "tests": {
      "description": "Build and run tests"
    },
    "tools": {
      "description": "Build executable tools and utilities"
    },
    "docs": {
      "description": "Build documentation"
    }
  }
}
```

**portfile.cmake** - Build script optimized for detected build system:
```cmake
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owner/repo
    REF commit-hash
    SHA512 0  # Auto-calculated on first build
    HEAD_REF main
)

# Windows DLL export handling (when needed)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

# Build system configuration (auto-selected)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # Disable components not needed in vcpkg by default
        -DBUILD_TESTING=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_DOC=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_TOOLS=OFF
        -DBUILD_EXECUTABLES=OFF
        -DBUILD_APPS=OFF
        # Feature-controlled options (when features are defined)
        -DBUILD_TESTING=${FEATURES tests}
        -DBUILD_TOOLS=${FEATURES tools}
        -DBUILD_DOCS=${FEATURES docs}
)
vcpkg_cmake_install()

# Standard vcpkg integration
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/package-name)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
```

**usage** - CMake integration guide for compiled libraries:
```cmake
package-name provides CMake targets:

  find_package(package-name CONFIG REQUIRED)
  target_link_libraries(main PRIVATE unofficial::package-name)
```

**usage** - CMake integration guide for header-only libraries:
```
package-name is header-only and can be used from CMake via:

  find_path(<PACKAGE_NAME>_INCLUDE_DIRS <primary-header.h>)
  target_include_directories(main PRIVATE ${<PACKAGE_NAME>_INCLUDE_DIRS})
```

> **Header-only usage pattern**: Do NOT use `find_package` for ports that only install headers with no CMake config. Use `find_path` to locate the include directory and `target_include_directories` to link it. The portfile must also explicitly install the usage file:
> ```cmake
> file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
> ```

## Example Analysis Results

| GitHub Repository | Port Name | Reasoning | Version Scheme |
|-------------------|-----------|-----------|----------------|
| `fmtlib/fmt` | `fmt` | Well-established across package managers | `"version": "10.2.1"` |
| `nlohmann/json` | `nlohmann-json` | Disambiguates generic "json" term | `"version": "3.11.3"` |
| `gabime/spdlog` | `spdlog` | Distinctive name, no conflicts | `"version": "1.12.0"` |
| `someuser/experimental-lib` | `someuser-experimental-lib` | No releases, needs disambiguation | `"version-date": "2026-03-16"` |

## Validation and Testing

**Post-Creation Checklist:**
- [ ] Build test: `vcpkg install {package-name}` 
- [ ] CMake integration: Test usage examples
- [ ] Version database: `vcpkg x-add-version {package-name}`
- [ ] CI validation: `vcpkg ci {package-name}`

**SHA512 Hash Workflow:**
1. Set `SHA512 0` initially in portfile.cmake
2. Run build - vcpkg provides correct hash in error message
3. Update portfile.cmake with calculated hash
4. Rebuild to complete installation

## Quick Start Workflow

**3-Step Process:**
1. **Input**: `create-port https://github.com/gabime/spdlog`
2. **Auto-Analysis**: Port name, version scheme, build system, and dependencies detected
3. **Generate**: Complete port structure ready for testing

**What gets auto-detected:**
- Port name with conflict resolution
- Version scheme (releases vs commit dates)
- Build system and required vcpkg helpers
- License files and SPDX identifiers
- Dependencies and CMake integration patterns

## Component Control Strategy

vcpkg ports should **disable non-essential components by default** to minimize build time, reduce dependencies, and focus on library distribution:

### Default Behavior
**Always disable by default:**
- **Tests** (unit tests, integration tests)
- **Documentation** (API docs, manuals)
- **Tools/Executables** (command-line utilities, examples)
- **Samples/Examples** (demo applications)

### Implementation Methods

**Method 1: CMake Options (Preferred)**
When upstream provides CMake options to control components:
```cmake
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # Common disable patterns
        -DBUILD_TESTING=OFF
        -DBUILD_TESTS=OFF 
        -DBUILD_DOCS=OFF
        -DBUILD_DOCUMENTATION=OFF
        -DBUILD_TOOLS=OFF
        -DBUILD_EXECUTABLES=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_SAMPLES=OFF
        # Project-specific options (analyze CMakeLists.txt)
        -DENABLE_TESTS=OFF
        -DWITH_TOOLS=OFF
)
```

**Method 2: vcpkg Features (Optional Control)**
Allow users to enable components via features:
```json
{
  "features": {
    "tests": {
      "description": "Build and install test executables"
    },
    "tools": {
      "description": "Build command-line utilities",
      "dependencies": ["boost-program-options"]  
    },
    "docs": {
      "description": "Build documentation",
      "dependencies": [{"name": "doxygen", "host": true}]
    }
  }
}
```

Then use feature-controlled options:
```cmake
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=${FEATURES tests}
        -DBUILD_TOOLS=${FEATURES tools}
        -DBUILD_DOCS=${FEATURES docs}
)
```

**Method 3: Patches (When No Options Exist)**
When upstream doesn't provide control options, create a patch that adds an option:
```cmake
# Example patch: add BUILD_SAMPLES option to upstream CMakeLists.txt
# Original:  if(PROJECT_IS_TOP_LEVEL)
#                add_subdirectory(samples)
#            endif()
# Patched:   option(BUILD_SAMPLES "Build sample applications" ON)
#            ...
#            if(PROJECT_IS_TOP_LEVEL AND BUILD_SAMPLES)
#                add_subdirectory(samples)
#            endif()
```
Then disable via `-DBUILD_SAMPLES=OFF` in portfile.cmake. This is preferred over
`file(REMOVE_RECURSE)` hacks because it produces a clean, reviewable patch and
avoids CMake errors when the upstream `add_subdirectory()` references a removed directory.

```cmake
# In portfile.cmake
vcpkg_from_github(
    # ... other parameters ...
    PATCHES
        disable-samples.patch
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SAMPLES=OFF
)
```

### Component Analysis Process

**Step 1: Examine Build System**
- Review `CMakeLists.txt` for component control options
- Look for `BUILD_*`, `ENABLE_*`, `WITH_*` variables
- Check `option()` declarations and conditional builds

**Step 2: Test Default Behavior**
- Build with minimal configuration to see what gets built
- Check if tests/tools/docs are built by default
- Identify unwanted executables or documentation

**Step 3: Apply Appropriate Method**
- Use upstream CMake options if available
- Create patches that add CMake options if none exist (preferred over source deletion)
- Add features for user-controllable components

### Common CMake Option Patterns

| Component Type | Common Option Names |
|----------------|--------------------|
| **Tests** | `BUILD_TESTING`, `BUILD_TESTS`, `ENABLE_TESTS`, `WITH_TESTS` |
| **Tools** | `BUILD_TOOLS`, `BUILD_EXECUTABLES`, `BUILD_APPS`, `BUILD_PROGRAMS` |
| **Docs** | `BUILD_DOCS`, `BUILD_DOCUMENTATION`, `ENABLE_DOCS`, `WITH_DOCS` |
| **Examples** | `BUILD_EXAMPLES`, `BUILD_SAMPLES`, `BUILD_DEMOS` |

## Dependency Management

### Vendored Dependency Removal
Ports should remove vendored dependencies and use vcpkg packages instead:

**Identification Process:**
- Scan for `vendor/`, `third-party/`, `deps/`, `external/` directories
- Check for Git submodules pointing to external libraries
- Look for embedded static libraries (`*.lib`, `*.a`)

**Replacement Strategy:**
1. **Check vcpkg availability**: `vcpkg search <dependency-name>`
2. **Verify API compatibility**: Check that the vcpkg port's API matches what the consuming project uses. A newer port may have breaking API changes (e.g., added/removed parameters, changed callback signatures). If incompatible, the vendored copy must be kept.
3. **Check for private/internal header usage**: Some libraries expose private headers (e.g., `MachineIndependent/localintermediate.h` for glslang, internal traversal APIs). If the project uses these, the vcpkg port will not install them and the vendored copy must be kept.
4. **Add to manifest**: Include existing vcpkg dependencies
5. **Create patches**: Remove vendored code and update build system to use `find_package()`
6. **Disable unnecessary components**: Use CMake options or patches to disable tests, tools, and documentation
7. **Create missing ports**: For dependencies not in vcpkg, create separate ports first
8. **Remove vendored sources in portfile**: Use `file(REMOVE_RECURSE)` in `portfile.cmake` BEFORE `vcpkg_cmake_configure` to delete bundled source trees so the build system is forced to use vcpkg-provided packages:
   ```cmake
   file(REMOVE_RECURSE "${SOURCE_PATH}/vendor/fmt")
   file(REMOVE "${SOURCE_PATH}/include/external/stb_image.h")
   ```

**Example Patch Transformation:**
```cmake
# Before: Vendored dependencies
add_subdirectory(vendor/fmt)
target_link_libraries(mylib PRIVATE fmt)

# After: vcpkg dependencies
find_package(fmt CONFIG REQUIRED)
target_link_libraries(mylib PRIVATE fmt::fmt)
```

**Unity-build style `.c` includes:** Some C projects inline-compile a dependency by `#include`-ing its `.c` file directly (unity build). When devendoring, remove the `.c` include entirely — the precompiled vcpkg library provides the symbols. Only keep the header include, updated to the system path:
```c
// Before (unity build — must remove when devendoring)
#include "../vendor/mylib/mylib.c"
#include "../vendor/mylib/mylib.h"

// After (use precompiled vcpkg library)
#include <mylib/mylib.h>
```

**Verifying CMake target names:** Do NOT guess the target name exported by a vcpkg port. Always check the installed CMake config to get the exact target:
```powershell
# Find the actual target name
Get-Content "installed/x64-windows/share/<port>/<port>-config.cmake"
# Or look for *Targets.cmake files
```
For example, `unofficial-spirv-reflect` exports `unofficial::spirv-reflect` (not `unofficial::spirv-reflect::spirv-reflect`), and its CMake config sets `INTERFACE_INCLUDE_DIRECTORIES` so the header is included as `<spirv_reflect.h>` directly.


### Tool Dependencies
For build-time tools, use vcpkg's tool acquisition:

**Priority Order:**
1. `vcpkg_find_acquire_program()` - For standard tools (Python, Perl, Flex, Bison, etc.)
2. **vcpkg tool ports** - Add as host dependencies (protobuf[tools], qt5-tools)
3. **Custom tools** - Create separate tool ports if needed

**Common Tool Examples:**
```cmake
# Standard tools via vcpkg_find_acquire_program
vcpkg_find_acquire_program(PYTHON3)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(BISON)

# Tool ports as host dependencies
{
  "dependencies": [
    {"name": "protobuf", "host": true, "features": ["tools"]}
  ]
}
```

## Patch Management

For source modifications, use the dedicated `create-patches` skill:
- **When to use**: Fixing build issues, adding CMake exports, removing vendored dependencies
- **Best practice**: Place patches in `ports/package-name/patches/` directory
- **Naming**: Number patches if order matters: `001-fix-cmake.patch`, `002-remove-vendor.patch`
- **Integration**: Use `PATCHES` parameter in `vcpkg_from_github()`

## Unsuitable Libraries

Some libraries are incompatible with vcpkg's packaging model:

**Incompatible Types:**
- Commercial licenses requiring end-user agreements
- Pre-compiled binaries with platform-specific dependencies
- System services, drivers, or kernel modules
- Tools/utilities (not libraries)
- Libraries for languages that are not C/C++ (e.g., Python, JavaScript, Rust)

**Pre-Analysis Checklist:**
- [ ] Builds from source without external binaries
- [ ] Dependencies available through vcpkg or system packages
- [ ] License permits redistribution
- [ ] Produces standard libraries/headers
- [ ] No system service dependencies

**Alternative Approaches:**
- System installation with integration documentation
- Tool dependencies for build-time utilities
- Wrapper libraries for vcpkg-compatible alternatives

## Best Practices Summary

### Port Creation
- **Use GitHub URLs** as primary input for automatic analysis
- **Follow naming guidelines** with repology.org and web search validation
- **Remove vendored dependencies** and replace with vcpkg packages
- **Choose appropriate build system helpers** based on auto-detection
- **Use `unofficial::` namespace** for all vcpkg-generated CMake targets

### Build System Integration  
- **Add required host dependencies** for build system support
- **Disable non-essential components** by default (tests, tools, documentation)
- **Handle Windows DLL issues** with conditional `vcpkg_check_linkage(ONLY_STATIC_LIBRARY)` inside `if(VCPKG_TARGET_IS_WINDOWS)` — do not force static globally unless the library cannot build shared on any platform
- **Set SHA512 to 0 initially** for auto-calculation on first build
- **Install usage files** with proper CMake integration examples
- **Use vcpkg features** to allow optional component building when appropriate

### Quality Assurance
- **Test across platforms** with different triplets
- **Validate CMake integration** works with generated targets
- **Use post-build validation** checklist for completeness
- **Update version database** after successful testing

## Static vs Dynamic Linkage

### Windows-Only Static Restriction
Libraries without `__declspec(dllexport)` annotations produce empty DLLs on Windows,
but work fine as shared libraries on non-Windows platforms (ELF and Mach-O export all
symbols by default). Use a **conditional** static linkage check:
```cmake
# Only restrict to static on Windows where dllexport is required
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
```
Do NOT use unconditional `vcpkg_check_linkage(ONLY_STATIC_LIBRARY)` unless the library
genuinely cannot build as a shared library on any platform.

## Patch Generation Workflow

### Recommended: Use `git format-patch` with File Output
When creating patches, initialize a git repo in the extracted source, make changes, and
generate patches to a file. **Do NOT pipe `git format-patch --stdout` through PowerShell**
as it mangles line endings. Use `-o <directory>` instead:

```powershell
# Extract clean sources (from buildtrees/ after a vcpkg build attempt)
cd buildtrees/package-name/src/<hash>.clean

# Initialize git and commit original state
git init
git add -A
git -c user.email="patch@vcpkg" -c user.name="vcpkg" commit -m "original"

# Make your modifications to the source files
# ... edit CMakeLists.txt, etc. ...

# Commit changes and generate patch directly to port directory
git add -A
git -c user.email="patch@vcpkg" -c user.name="vcpkg" commit -m "Descriptive change message"
git format-patch -1 -o "path/to/ports/package-name"

# Rename to a descriptive name
Rename-Item "ports/package-name/0001-Descriptive-change-message.patch" "descriptive-name.patch"
```

**IMPORTANT**: Never use `git format-patch --stdout | Set-Content` on Windows — PowerShell
corrupts the line endings, producing a single-line file that cannot be applied.

## Version Database Workflow

After creating or updating a port, register it in the version database:

```powershell
# 1. Format the manifest (required before x-add-version)
vcpkg format-manifest ports/package-name/vcpkg.json

# 2. Stage port files (x-add-version reads from git index)
git add ports/package-name

# 3. Add version entry
vcpkg x-add-version package-name

# 4. Stage the generated version files and commit
git add versions/
git commit -m "[package-name] Add new port"
```

## Testing and Troubleshooting

### Build Validation Commands
```powershell
# Initial build (calculates SHA512 if set to 0)
vcpkg install {package-name}

# Update portfile.cmake with calculated SHA512 from error message, then:
vcpkg install {package-name}  # Complete the build

# Version database validation
vcpkg x-add-version {package-name}
vcpkg x-ci-verify-versions
```

### Common Issues and Solutions

**Missing CMake Functions:**
```
Unknown CMake command "vcpkg_cmake_configure"
```
**Solution:** Add vcpkg-cmake dependencies to vcpkg.json:
```json
{"dependencies": [{"name": "vcpkg-cmake", "host": true}, {"name": "vcpkg-cmake-config", "host": true}]}
```

**Windows DLL Export Issues:**
```
DLLs were built without any exports
```
**Solution:** Add to portfile.cmake:
```cmake
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
```

**Usage File Not Installed:**
```
this port contains a file named "usage" but didn't install it
```
**Solution:** Add installation command to portfile.cmake:
```cmake
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
```

**Incorrect SHA512 Hash:**
1. Set `SHA512 0` initially in portfile.cmake
2. Build fails with calculated hash in error message
3. Update portfile.cmake with correct hash
4. Rebuild to complete installation

**License embedded in header (no separate LICENSE file):**
Some single-header libraries embed the license text at the bottom of the header itself. Use the header as the copyright source:
```cmake
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/mylib.h")
```

**Modifying an existing port (usage file, portfile changes):**
Any change to an existing port requires incrementing `port-version` and updating the versions database:
```json
{ "port-version": 1 }  // increment from previous value
```
```powershell
vcpkg x-add-version <port-name>
```
This applies even for minor changes like adding a usage file or fixing install paths.

### Success Indicators
- ✅ No post-build warnings
- ✅ Usage file installed to `share/` directory
- ✅ CMake targets use `unofficial::` namespace
- ✅ License files in `share/package-name/copyright`
- ✅ Clean directory structure (no empty debug folders)

## Next Steps

After successful port creation:
1. **Test thoroughly** across supported platforms
2. **Submit PR** to microsoft/vcpkg repository following contribution guidelines
3. **Monitor CI** for platform-specific issues and respond to feedback
4. **Update documentation** if special integration steps are required
