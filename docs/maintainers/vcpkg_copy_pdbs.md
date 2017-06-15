# vcpkg_copy_pdbs

Automatically locate pdbs in the build tree and copy them adjacent to all DLLs.

## Usage
```cmake
vcpkg_copy_pdbs()
```

## Notes
This command should always be called by portfiles after they have finished rearranging the binary output.

## Examples

* [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
* [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)

## Source
[scripts/cmake/vcpkg_copy_pdbs.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_copy_pdbs.cmake)
