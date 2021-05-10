# vcpkg_copy_pdbs

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_copy_pdbs.md).

Automatically locate pdbs in the build tree and copy them adjacent to all DLLs.

```cmake
vcpkg_copy_pdbs(
    [BUILD_PATHS <glob>...])
```

The `<glob>`s are patterns which will be passed to `file(GLOB_RECURSE)`,
for locating DLLs. It defaults to using:

- `${CURRENT_PACKAGES_DIR}/bin/*.dll`
- `${CURRENT_PACKAGES_DIR}/debug/bin/*.dll`

since that is generally where DLLs are located.

## Notes
This command should always be called by portfiles after they have finished rearranging the binary output.

## Examples

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_copy\_pdbs.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_copy_pdbs.cmake)
