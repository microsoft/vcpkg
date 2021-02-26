# vcpkg_extract_source_archive_ex

Extract an archive into the source directory. Replaces [`vcpkg_extract_source_archive`](vcpkg_extract_source_archive.md).

## Usage
```cmake
vcpkg_extract_source_archive_ex(
    SKIP_PATCH_CHECK
    OUT_SOURCE_PATH <SOURCE_PATH>
    ARCHIVE <${ARCHIVE}>
    [REF <1.0.0>]
    [NO_REMOVE_ONE_LEVEL]
    [WORKING_DIRECTORY <${CURRENT_BUILDTREES_DIR}/src>]
    [PATCHES <a.patch>...]
)
```
## Parameters
### SKIP_PATCH_CHECK
If this option is set the failure to apply a patch is ignored.

### OUT_SOURCE_PATH
Specifies the out-variable that will contain the extracted location.

This should be set to `SOURCE_PATH` by convention.

### ARCHIVE
The full path to the archive to be extracted.

This is usually obtained from calling [`vcpkg_download_distfile`](vcpkg_download_distfile.md).

### REF
A friendly name that will be used instead of the filename of the archive.  If more than 10 characters it will be truncated.

By convention, this is set to the version number or tag fetched

### WORKING_DIRECTORY
If specified, the archive will be extracted into the working directory instead of `${CURRENT_BUILDTREES_DIR}/src/`.

Note that the archive will still be extracted into a subfolder underneath that directory (`${WORKING_DIRECTORY}/${REF}-${HASH}/`).

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

### NO_REMOVE_ONE_LEVEL
Specifies that the default removal of the top level folder should not occur.

## Examples

* [bzip2](https://github.com/Microsoft/vcpkg/blob/master/ports/bzip2/portfile.cmake)
* [sqlite3](https://github.com/Microsoft/vcpkg/blob/master/ports/sqlite3/portfile.cmake)
* [cairo](https://github.com/Microsoft/vcpkg/blob/master/ports/cairo/portfile.cmake)

## Source
[scripts/cmake/vcpkg_extract_source_archive_ex.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_extract_source_archive_ex.cmake)
