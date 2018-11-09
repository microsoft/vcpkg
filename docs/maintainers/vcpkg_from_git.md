# vcpkg_from_git

Download and extract a project from git

## Usage:
```cmake
vcpkg_from_git(
    OUT_SOURCE_PATH <SOURCE_PATH>
    URL <https://android.googlesource.com/platform/external/fdlibm>
    REF <59f7335e4d...>
    SHA512 <abcdef123...>
    [PATCHES <patch1.patch> <patch2.patch>...]
)
```

## Parameters:
### OUT_SOURCE_PATH
Specifies the out-variable that will contain the extracted location.

This should be set to `SOURCE_PATH` by convention.

### URL
The url of the git repository.

### SHA512
The SHA512 hash that should match the archive form of the commit.

This is most easily determined by first setting it to `0`, then trying to build the port. The error message will contain the full hash, which can be copied back into the portfile.

### REF
A stable git commit-ish (ideally a tag or commit) that will not change contents. **This should not be a branch.**

For repositories without official releases, this can be set to the full commit id of the current latest master.

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

## Notes:
`OUT_SOURCE_PATH`, `REF`, `SHA512`, and `URL` must be specified.

## Examples:

* [fdlibm](https://github.com/Microsoft/vcpkg/blob/master/ports/fdlibm/portfile.cmake)

## Source
[scripts/cmake/vcpkg_from_git.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_from_git.cmake)
