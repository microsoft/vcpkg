# vcpkg_find_acquire_program

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_find_acquire_program.md).

Download or find a well-known tool.

## Usage
```cmake
vcpkg_find_acquire_program(<program>)
```
## Parameters
### program
This variable specifies both the program to be acquired as well as the out parameter that will be set to the path of the program executable.

## Notes
The current list of programs includes:

* 7Z
* ARIA2 (Downloader)
* BISON
* CLANG
* DARK
* DOXYGEN
* FLEX
* GASPREPROCESSOR
* GPERF
* PERL
* PYTHON2
* PYTHON3
* GIT
* GN
* GO
* JOM
* MESON
* NASM
* NINJA
* NUGET
* SCONS
* SWIG
* YASM

Note that msys2 has a dedicated helper function: [`vcpkg_acquire_msys`](vcpkg_acquire_msys.md).

## Examples

* [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
* [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
* [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)

## Source
[scripts/cmake/vcpkg\_find\_acquire\_program.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_find_acquire_program.cmake)
