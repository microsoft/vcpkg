# vcpkg_from_git

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_from_git.md).

Download and extract a project from git

## Usage:
```cmake
vcpkg_from_git(
    OUT_SOURCE_PATH <SOURCE_PATH>
    URL <https://android.googlesource.com/platform/external/fdlibm>
    REF <59f7335e4d...>
    [HEAD_REF <ref>]
    [PATCHES <patch1.patch> <patch2.patch>...]
    [LFS]
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

### FETCH_REF
The git branch to fetch in non-HEAD mode. After this is fetched,
then `REF` is checked out. This is useful in cases where the git server
does not allow checking out non-advertised objects.

### HEAD_REF
The git branch to use when the package is requested to be built from the latest sources.

Example: `main`, `develop`, `HEAD`

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

### LFS
Enable fetching files stored using Git LFS.
Only files pointed to by `REF` are fetched.

This makes Git LFS mandatory for the port.
It's a fatal error if the extension is not installed.

## Notes:
`OUT_SOURCE_PATH`, `REF`, and `URL` must be specified.

## Examples:

* [fdlibm](https://github.com/Microsoft/vcpkg/blob/master/ports/fdlibm/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_from\_git.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_from_git.cmake)
