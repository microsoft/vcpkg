# vcpkg Portfile Functions Reference

## Source Acquisition Functions

### vcpkg_from_github()
Downloads source code from GitHub repositories.
```cmake
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owner/repo-name
    REF version-tag-or-sha
    SHA512 hash-of-archive
    HEAD_REF main-branch-name
    PATCHES
        fix-build.patch
        fix-install.patch
)
```

### vcpkg_download_distfile()
Downloads files from arbitrary URLs.
```cmake
vcpkg_download_distfile(ARCHIVE
    URLS "https://example.com/archive.tar.gz"
    FILENAME "archive.tar.gz"
    SHA512 hash-of-file
)
```

## Build Configuration Functions

### vcpkg_cmake_configure()
Configures CMake-based projects.
```cmake
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
    OPTIONS_DEBUG
        -DDEBUG_POSTFIX=d
    OPTIONS_RELEASE
        -DOPTIMIZE=ON
)
```

### vcpkg_cmake_install()
Builds and installs CMake projects.
```cmake
vcpkg_cmake_install()
```

## Post-Install Functions

### vcpkg_cmake_config_fixup()
Fixes CMake config files for proper target exports.
```cmake
vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/PackageName
    PACKAGE_NAME PackageName
)
```

### vcpkg_fixup_pkgconfig()
Fixes pkg-config files.
```cmake
vcpkg_fixup_pkgconfig()
```

### vcpkg_copy_pdbs()
Copies debugging symbols on Windows.
```cmake
vcpkg_copy_pdbs()
```

### vcpkg_install_copyright()
Installs license files.
```cmake
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
```

## Feature Management

### vcpkg_check_features()
Converts vcpkg features to CMake options.
```cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl         ENABLE_SSL
        compression ENABLE_ZLIB
        doc         BUILD_DOCUMENTATION
)
```

## Advanced Functions

### vcpkg_execute_build_process()
Executes custom build commands.
```cmake
vcpkg_execute_build_process(
    COMMAND make -j${VCPKG_CONCURRENCY}
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build
)
```

### vcpkg_apply_patches()
Applies patch files to source code.
```cmake
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        fix-cmakelists.patch
        add-install-target.patch
)
```

## Best Practices

1. **Always verify SHA512 hashes** for security
2. **Use vcpkg helpers** instead of raw commands when possible
3. **Support both static and shared builds** unless technically impossible
4. **Remove debug-only files** from release builds
5. **Install copyright files** for legal compliance
6. **Use modern CMake targets** in usage files