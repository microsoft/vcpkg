# vcpkg_copy_pdbs

Automatically locate pdbs in the build tree and copy them adjacent to all DLLs.

## Usage
```cmake
vcpkg_copy_pdbs([BUILD_PATHS <${CURRENT_PACKAGES_DIR}/bin/*.dll> ...])
```

## Notes
This command should always be called by portfiles after they have finished rearranging the binary output.

## Parameters
### BUILD_PATHS
Path patterns passed to `file(GLOB_RECURSE)` for locating dlls.

Defaults to `${CURRENT_PACKAGES_DIR}/bin/*.dll` and `${CURRENT_PACKAGES_DIR}/debug/bin/*.dll`.

## Examples

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)

## Source
[scripts/cmake/vcpkg_copy_pdbs.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_copy_pdbs.cmake)
