# vcpkg_extract_source_archive

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_extract_source_archive.md).

Extract an archive into the source directory.

## Usage
There are two "overloads" of this function. The first is deprecated:

```cmake
vcpkg_extract_source_archive(<${ARCHIVE}> [<${TARGET_DIRECTORY}>])
```

This overload should not be used.

The latter is suggested to use for all future `vcpkg_extract_source_archive`s.

```cmake
vcpkg_extract_source_archive(<out-var>
    ARCHIVE <path>
    [NO_REMOVE_ONE_LEVEL]
    [SKIP_PATCH_CHECK]
    [PATCHES <patch>...]
    [SOURCE_BASE <base>]
    [BASE_DIRECTORY <relative-path> | WORKING_DIRECTORY <absolute-path>]
)
```

`vcpkg_extract_source_archive` takes an archive and extracts it.
It replaces existing uses of `vcpkg_extract_source_archive_ex`.
The simplest use of it is:

```cmake
vcpkg_download_distfile(archive ...)
vcpkg_extract_source_archive(source_path ARCHIVE "${archive}")
```

The general expectation is that an archives are laid out with a base directory,
and all the actual files underneath that directory; in other words, if you
extract the archive, you'll get something that looks like:

```
zlib-1.2.11/
    doc/
        ...
    examples/
        ...
    ChangeLog
    CMakeLists.txt
    README
    zlib.h
    ...
```

`vcpkg_extract_source_archive` automatically removes this directory,
and gives you the items under it directly. However, this only works
when there is exactly one item in the top level of an archive.
Otherwise, you'll have to pass the `NO_REMOVE_ONE_LEVEL` argument to
prevent `vcpkg_extract_source_archive` from performing this transformation.

If the source needs to be patched in some way, the `PATCHES` argument
allows one to do this, just like other `vcpkg_from_*` functions.
Additionally, the `SKIP_PATCH_CHECK` is provided for `--head` mode -
this allows patches to fail to apply silently.
This argument should _only_ be used when installing a `--head` library,
since otherwise we want a patch failing to appply to be a hard error.

`vcpkg_extract_source_archive` extracts the files to
`${CURRENT_BUILDTREES_DIR}/<base-directory>/<source-base>-<hash>.clean`.
When in editable mode, no `.clean` is appended,
to allow for a user to modify the sources.
`base-directory` defaults to `src`,
and `source-base` defaults to the stem of `<archive>`.
You can change these via the `BASE_DIRECTORY` and `SOURCE_BASE` arguments
respectively.
If you need to extract to a location that is not based in `CURRENT_BUILDTREES_DIR`,
you can use the `WORKING_DIRECTORY` argument to do the same.

## Examples

* [libraw](https://github.com/Microsoft/vcpkg/blob/master/ports/libraw/portfile.cmake)
* [protobuf](https://github.com/Microsoft/vcpkg/blob/master/ports/protobuf/portfile.cmake)
* [msgpack](https://github.com/Microsoft/vcpkg/blob/master/ports/msgpack/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_extract\_source\_archive.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_extract_source_archive.cmake)
