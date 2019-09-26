# vcpkg_fixup_cmake_targets

Transforms all /debug/share/<port>/*targets-debug.cmake files and move them to /share/<port>.
Removes all /debug/share/<port>/*targets.cmake and /debug/share/<port>/*config.cmake

Transforms all references matching /bin/*.exe to /tools/<port>/*.exe on Windows
Transforms all references matching /bin/* to /tools/<port>/* on other platforms

Fix ${_IMPORT_PREFIX} in auto generated targets to be one folder deeper. 
Replace ${CURRENT_INSTALLED_DIR} with ${_IMPORT_PREFIX} in configs/targets.


## Usage
```cmake
vcpkg_fixup_cmake_targets(CONFIG_PATH <config_path>)
```

## Parameters:
### CONFIG_PATH
*.cmake files subdirectory (usually like "lib/cmake/${PORT}").

## Source
[scripts/cmake/cmake_fixup_cmake_targets.cmake](https://github.com/microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_fixup_cmake_targets.cmake)