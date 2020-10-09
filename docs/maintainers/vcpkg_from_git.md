# vcpkg_from_git

Download and extract a project from git

## Usage:
```cmake
vcpkg_from_git(
    OUT_SOURCE_PATH <SOURCE_PATH>
    URL <https://android.googlesource.com/platform/external/fdlibm>
    REF <59f7335e4d...>
    SHA512 <abc123fed...>
    [PATCHES <patch1.patch> <patch2.patch>...]
)
```

## Parameters:
### OUT_SOURCE_PATH
Specifies the out-variable that will contain the extracted location.

This should be set to `SOURCE_PATH` by convention.

### URL
The url of the git repository.

### REF
The git sha of the commit to download.

### SHA512
The SHA512 hash of the intermediate archive tarball.

This helper uses `git archive` to convert the given commit into a flat
.tar.gz archive; this is the hash of that archive.

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

## Notes:
`OUT_SOURCE_PATH`, `REF`, `SHA512`, and `URL` must be specified.

## Examples:

* [fdlibm](https://github.com/Microsoft/vcpkg/blob/master/ports/fdlibm/portfile.cmake)

## Source
[scripts/cmake/vcpkg_from_git.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_from_git.cmake)
