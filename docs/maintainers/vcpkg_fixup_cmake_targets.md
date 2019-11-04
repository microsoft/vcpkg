# vcpkg_fixup_cmake_targets

Transforms all `/debug/share/\<port\>/\*targets-debug.cmake` files and move them to `/share/\<port\>`.
Removes all `/debug/share/\<port\>/\*targets.cmake and /debug/share/\<port\>/\*config.cmake`.

Transforms all references matching `/bin/\*.exe tools/\<port\>/\*.exe` on Windows.
Transforms all references matching `/bin/\* to /tools/\<port\>/\*` on other platforms.

Fixups *${_IMPORT_PREFIX}* in auto generated targets to be one folder deeper. 
Replaces *${CURRENT_INSTALLED_DIR}* with *${_IMPORT_PREFIX}* in config files and targets.


## Usage
```cmake
vcpkg_fixup_cmake_targets(CONFIG_PATH <config_path>)
```

## Parameters:
### CONFIG_PATH
*.cmake files subdirectory (e.g. "lib/cmake/${PORT}" or "cmake/${PORT}).
### TARGET_PATH
Optional location to place fixup'd files. Unecessary if target is "share/${PORT}".

## Examples:
  - [Azure-uamqp-c](https://github.com/microsoft/vcpkg/blob/master/ports/azure-uamqp-c/portfile.cmake)
  - [Brigand](https://github.com/microsoft/vcpkg/blob/master/ports/brigand/portfile.cmake)
  - [cctz](https://github.com/microsoft/vcpkg/blob/master/ports/cctz/portfile.cmake)

## Source
[scripts/cmake/vcpkg_fixup_cmake_targets.cmake](https://github.com/microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_fixup_cmake_targets.cmake)
