# vcpkg_fixup_pkgconfig

Fix common paths in *.pc files and make everything relativ to $(prefix)

## Usage
```cmake
vcpkg_fixup_pkgconfig(
    [RELEASE_FILES <PATHS>...]
    [DEBUG_FILES <PATHS>...]
    [SYSTEM_LIBRARIES <NAMES>...]
)
```

## Parameters
### RELEASE_FILES
Specifies a list of files to apply the fixes for release paths.
Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR} without ${CURRENT_PACKAGES_DIR}/debug/

### DEBUG_FILES
Specifies a list of files to apply the fixes for debug paths.
Defaults to every *.pc file in the folder ${CURRENT_PACKAGES_DIR}/debug/

### SYSTEM_PACKAGES
If the *.pc file contains system packages outside vcpkg these need to be listed here.
Since vcpkg checks the existence of all required packages within vcpkg.

### SYSTEM_LIBRARIES
If the *.pc file contains system libraries outside vcpkg these need to be listed here.
VCPKG checks every -l flag for the existence of the required library within vcpkg.

### IGNORE_FLAGS
If the *.pc file contains flags in the lib field which are not libraries. These can be listed here

## Notes
Still work in progress. If there are more cases which can be handled here feel free to add them

## Examples

Just call vcpkg_fixup_pkgconfig() after any install step which installs *.pc files.

## Source
[scripts/cmake/vcpkg_fixup_pkgconfig.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_fixup_pkgconfig.cmake)
