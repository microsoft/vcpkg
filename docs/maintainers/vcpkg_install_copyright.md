# vcpkg_install_copyright

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_install_copyright.md).

Merges multiple copyright files into a single file and install it.

## Usage:

```cmake
vcpkg_install_copyright(FILE_LIST <license.md> <license_gpl.md>...)
```

## Parameters:

### FILE_LIST

Specifies a list of license files relative to `${SOURCE_PATH}`. You must provide at least 2 files.

If you want to install just a single license file, please use

```cmake
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
```

## Notes

This function concatinates the contents of multiple copyright files to a single file.

The resulting `copyright` file looks similar to this:

```
LICENSE-LGPL2.txt:

Lorem ipsum dolor...

LICENSE-MIT.txt:

Lorem ipsum dolor sit amet...
```
