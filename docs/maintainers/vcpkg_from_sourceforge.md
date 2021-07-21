# vcpkg_from_sourceforge

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_from_sourceforge.md).

Download and extract a project from sourceforge.

This function automatically checks a set of sourceforge mirrors.
Additional mirrors can be injected through the `VCPKG_SOURCEFORGE_EXTRA_MIRRORS`
list variable in the triplet.

## Usage:
```cmake
vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO <cunit/CUnit>
    [REF <2.1-3>]
    SHA512 <547b417109332...>
    FILENAME <CUnit-2.1-3.tar.bz2>
    [DISABLE_SSL]
    [NO_REMOVE_ONE_LEVEL]
    [PATCHES <patch1.patch> <patch2.patch>...]
)
```

## Parameters:
### OUT_SOURCE_PATH
Specifies the out-variable that will contain the extracted location.

This should be set to `SOURCE_PATH` by convention.

### REPO
The organization or user and repository (optional) on sourceforge.

### REF
A stable version number that will not change contents.

### FILENAME
The local name for the file. Files are shared between ports, so the file may need to be renamed to make it clearly attributed to this port and avoid conflicts.

For example, we can get the download link:
https://sourceforge.net/settings/mirror_choices?projectname=mad&filename=libmad/0.15.1b/libmad-0.15.1b.tar.gz&selected=nchc
So the REPO is `mad/libmad`, the REF is `0.15.1b`, and the FILENAME is `libmad-0.15.1b.tar.gz`

For some special links:
https://sourceforge.net/settings/mirror_choices?projectname=soxr&filename=soxr-0.1.3-Source.tar.xz&selected=nchc
The REPO is `soxr`, REF is not exist, and the FILENAME is `soxr-0.1.3-Source.tar.xz`

### SHA512
The SHA512 hash that should match the archive.

This is most easily determined by first setting it to `0`, then trying to build the port. The error message will contain the full hash, which can be copied back into the portfile.

### WORKING_DIRECTORY
If specified, the archive will be extracted into the working directory instead of `${CURRENT_BUILDTREES_DIR}/src/`.

Note that the archive will still be extracted into a subfolder underneath that directory (`${WORKING_DIRECTORY}/${REF}-${HASH}/`).

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

### NO_REMOVE_ONE_LEVEL
Specifies that the default removal of the top level folder should not occur.

## Examples:

* [cunit](https://github.com/Microsoft/vcpkg/blob/master/ports/cunit/portfile.cmake)
* [polyclipping](https://github.com/Microsoft/vcpkg/blob/master/ports/polyclipping/portfile.cmake)
* [tinyfiledialogs](https://github.com/Microsoft/vcpkg/blob/master/ports/tinyfiledialogs/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_from\_sourceforge.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_from_sourceforge.cmake)
