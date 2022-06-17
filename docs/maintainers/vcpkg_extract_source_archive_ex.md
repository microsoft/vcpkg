# vcpkg_extract_source_archive_ex

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_extract_source_archive_ex.md).

Extract an archive.

This command is replaced by [`vcpkg_extract_source_archive()`][].

## Usage
```cmake
vcpkg_extract_source_archive_ex(
    [OUT_SOURCE_PATH <out-var>]
    [<options>...]
)
```

This command forwards all options to `vcpkg_extract_source_archive()`, with the `<out-var>` as the first argument. See the documentation for [`vcpkg_extract_source_archive()`] for parameter help.

[`vcpkg_extract_source_archive()`]: vcpkg_extract_source_archive.md

## Source
[scripts/cmake/vcpkg\_extract\_source\_archive\_ex.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_extract_source_archive_ex.cmake)
