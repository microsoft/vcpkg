# vcpkg_extract_source_archive

Extract an archive into the source directory. Deprecated in favor of [`vcpkg_extract_source_archive_ex`](vcpkg_extract_source_archive_ex.md).

## Usage
```cmake
vcpkg_extract_source_archive(
    <${ARCHIVE}> [<${TARGET_DIRECTORY}>]
)
```
## Parameters
### ARCHIVE
The full path to the archive to be extracted.

This is usually obtained from calling [`vcpkg_download_distfile`](vcpkg_download_distfile.md).

### TARGET_DIRECTORY
If specified, the archive will be extracted into the target directory instead of `${CURRENT_BUILDTREES_DIR}/src/`.

This can be used to mimic git submodules, by extracting into a subdirectory of another archive.

## Notes
This command will also create a tracking file named <FILENAME>.extracted in the TARGET_DIRECTORY. This file, when present, will suppress the extraction of the archive.

## Examples

* [libraw](https://github.com/Microsoft/vcpkg/blob/master/ports/libraw/portfile.cmake)
* [protobuf](https://github.com/Microsoft/vcpkg/blob/master/ports/protobuf/portfile.cmake)
* [msgpack](https://github.com/Microsoft/vcpkg/blob/master/ports/msgpack/portfile.cmake)

## Source
[scripts/cmake/vcpkg_extract_source_archive.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_extract_source_archive.cmake)
