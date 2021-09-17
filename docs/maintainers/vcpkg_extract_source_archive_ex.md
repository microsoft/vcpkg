# vcpkg_extract_source_archive_ex

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_extract_source_archive_ex.md).

Extract an archive into the source directory.
Originally replaced [`vcpkg_extract_source_archive()`],
but new ports should instead use the second overload of
[`vcpkg_extract_source_archive()`].

## Usage
```cmake
vcpkg_extract_source_archive_ex(
    [OUT_SOURCE_PATH <source_path>]
    ...
)
```

See the documentation for [`vcpkg_extract_source_archive()`] for other parameters.
Additionally, `vcpkg_extract_source_archive_ex()` adds the `REF` and `WORKING_DIRECTORY`
parameters, which are wrappers around `SOURCE_BASE` and `BASE_DIRECTORY`
respectively.

[`vcpkg_extract_source_archive()`]: vcpkg_extract_source_archive.md

## Source
[scripts/cmake/vcpkg\_extract\_source\_archive\_ex.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_extract_source_archive_ex.cmake)
