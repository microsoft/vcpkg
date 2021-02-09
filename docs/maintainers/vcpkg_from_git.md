# vcpkg_from_git

Download and extract a project from git

## Usage:
```cmake
vcpkg_from_git(
    OUT_SOURCE_PATH <SOURCE_PATH>
    URL <https://android.googlesource.com/platform/external/fdlibm>
    REF <59f7335e4d...>
    [TAG <v1.0.2>]
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

### TAG
An optional git tag to be verified against the `REF`. If the remote repository's tag does not match the specified `REF`, the build will fail.

### PATCHES
A list of patches to be applied to the extracted sources.

Relative paths are based on the port directory.

### X_OUT_REF (internal only)
This parameter is used for automatic REF updates for certain ports in the central vcpkg catalog. It should not be used by any ports outside the central catalog and within the central catalog it should not be used on any user path. This parameter may change behavior incompatibly or be removed at any time.

## Notes:
`OUT_SOURCE_PATH`, `REF`, and `URL` must be specified.

## Examples:

* [fdlibm](https://github.com/Microsoft/vcpkg/blob/master/ports/fdlibm/portfile.cmake)

## Source
[scripts/cmake/vcpkg_from_git.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_from_git.cmake)
