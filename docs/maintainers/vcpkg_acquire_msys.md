# vcpkg_acquire_msys

Download and prepare an MSYS2 instance.

## Usage
```cmake
vcpkg_acquire_msys(<MSYS_ROOT_VAR>)
```

## Parameters
### MSYS_ROOT_VAR
An out-variable that will be set to the path to MSYS2.

## Notes
A call to `vcpkg_acquire_msys` will usually be followed by a call to `bash.exe`:
```cmake
vcpkg_acquire_msys(MSYS_ROOT)
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc "${CMAKE_CURRENT_LIST_DIR}\\build.sh"
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME build-${TARGET_TRIPLET}-rel
)
```
To ensure a package is available:
```cmake
vcpkg_acquire_msys(MSYS_ROOT)
set(BASH ${MSYS_ROOT}/usr/bin/bash.exe)

message(STATUS "Installing MSYS Packages")
vcpkg_execute_required_process(
    COMMAND
        ${BASH} --noprofile --norc -c
            'PATH=/usr/bin:\$PATH pacman -Sy --noconfirm --needed make'
    WORKING_DIRECTORY ${MSYS_ROOT}
    LOGNAME pacman-${TARGET_TRIPLET})
```

## Examples

* [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
* [icu](https://github.com/Microsoft/vcpkg/blob/master/ports/icu/portfile.cmake)
* [libvpx](https://github.com/Microsoft/vcpkg/blob/master/ports/libvpx/portfile.cmake)

## Source
[scripts/cmake/vcpkg_acquire_msys.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_acquire_msys.cmake)
