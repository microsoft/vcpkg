# vcpkg_extract_source_archive_ex

**This function has been deprecated in favor of [`vcpkg_extract_source_archive()`].**

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_extract_source_archive_ex.md).

Extract an archive.

## Usage
```cmake
vcpkg_extract_source_archive_ex(
    [OUT_SOURCE_PATH <out-var>]
    [<options>...]
)
```

This command forwards all options to [`vcpkg_extract_source_archive()`], with `<out-var>` as the first argument. Equivalent to `vcpkg_extract_source_archive(<out-var> <options>...)`. See the documentation for [`vcpkg_extract_source_archive()`] for parameter help.

[`vcpkg_extract_source_archive()`]: vcpkg_extract_source_archive.md

## Source
[scripts/cmake/vcpkg\_extract\_source\_archive\_ex.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_extract_source_archive_ex.cmake)
