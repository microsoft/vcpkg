# vcpkg_extract_source_archive

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_extract_source_archive.md).

Extract an archive.

## Usage
```cmake
vcpkg_extract_source_archive(
    <out-var>
    ARCHIVE <path>
    [NO_REMOVE_ONE_LEVEL]
    [SKIP_PATCH_CHECK]
    [PATCHES <patch>...]
    [SOURCE_BASE <base>]
    [BASE_DIRECTORY <relative-path> | WORKING_DIRECTORY <absolute-path>]
)
```

## Parameters

<a id="out-var"></a>

### `<out-var>`

Name of the variable to set with the directory containing the extracted contents.

### ARCHIVE

Full path to the archive to extract.

### NO_REMOVE_ONE_LEVEL

Skip removing the top level directory of the archive.

Most archives contain a single top-level directory, such as:

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

By default, `vcpkg_extract_source_archive` removes this directory and moves all contents into the directory returned in `<out-var>`. If there is no top-level directory, it is an error.

With this flag, the top-level directory will be preserved and it is not an error to not have one.

### SKIP_PATCH_CHECK

Silence and ignore errors when applying patches.

This option should only be passed when operating in an unstable mode like `--head`. If the sources are pinned, failing to apply a patch should be considered a fatal error.

### PATCHES

List of patches to apply to the extracted source.

Patches will be applied in order, after any top-level directories are removed (see [`NO_REMOVE_ONE_LEVEL`](#no_remove_one_level)). Relative paths are interpreted relative to the current port directory.

If a patch should be conditionally applied based on target information, you can construct a list and splat it.

```cmake
set(patches "")
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND patches only-windows.patch)
endif()
vcpkg_extract_source_archive(src
    ARCHIVE "${archive}"
    PATCHES
        always-applied.patch
        ${patches}
)
```

### SOURCE_BASE

Pretty name for the extracted directory.

Must not contain path separators (`/` or `\\`).

See [`WORKING_DIRECTORY`](#working_directory) for more details.

### BASE_DIRECTORY

Root subfolder for the extracted directory.

Defaults to `src`. Must be a relative path.

See [`WORKING_DIRECTORY`](#working_directory) for more details.

### WORKING_DIRECTORY

Root folder for the extracted directory.

Defaults to `${CURRENT_BUILDTREES_DIR}/<BASE_DIRECTORY>`. Must be an absolute path.

`vcpkg_extract_source_archive` extracts the archive into `<WORKING_DIRECTORY>/<SOURCE_BASE>-<short-hash>.clean`. If the folder exists, it is deleted before extraction. Without specifying `SOURCE_BASE`, `BASE_DIRECTORY`, or `WORKING_DIRECTORY`, this will default to `${CURRENT_BUILDTREES_DIR}/src/<archive-stem>-<short-hash>.clean`.

In [`--editable`](../commands/install.md#editable) mode:
1. No `.clean` suffix is added to the extracted folder
2. The extracted folder is not deleted. If it exists, `vcpkg_extract_source_archive` does nothing.

`<short-hash>` unambiguously identifies a particular set of archive and patch file contents.
Any modifications to the contents of the working directory after calling this function should be applied unconditionally
in order to avoid unexpected behavior in editable mode.

## Examples

```cmake
vcpkg_download_distfile(
    archive # "archive" is set to the path to the downloaded file
    URLS "https://nmap.org/dist/nmap-7.70.tar.bz2"
    FILENAME "nmap-7.70.tar.bz2"
    SHA512 084c148b022ff6550e269d976d0077f7932a10e2ef218236fe13aa3a70b4eb6506df03329868fc68cb3ce78e4360b200f5a7a491d3145028fed679ef1c9ecae5
)
vcpkg_extract_source_archive(
    src # "src" is set to the path to the extracted files
    ARCHIVE "${archive}"
    SOURCE_BASE nmap.org-nmap-7.70
    PATCHES
        0001-disable-werror.patch
)
vcpkg_cmake_configure(SOURCE_PATH "${src}")
```

* [GitHub Search](https://github.com/microsoft/vcpkg/search?q=vcpkg_extract_source_archive+path%3A%2Fports)

## Remarks

**Deprecated Syntax**

This command also supports a deprecated overload:

```cmake
vcpkg_extract_source_archive(<archive> [<working_directory>])
```

The deprecated overload extracts `<archive>` into `${working_directory}/<archive-filename>.extracted` if the target does not exist. This incorrect behavior allows patches and other modifications to leak between different builds, resulting in hard-to-debug errors.

All uses of the deprecated overload should be replaced with the syntax in [Usage](#usage) above by adding an explicit [`ARCHIVE`](#archive) parameter and replacing direct references to the extracted path with uses of the [`<out-var>`](#out-var).

**Replacement**

This command replaces [`vcpkg_extract_source_archive_ex()`](vcpkg_extract_source_archive_ex.md).

## Source
[scripts/cmake/vcpkg\_extract\_source\_archive.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_extract_source_archive.cmake)
