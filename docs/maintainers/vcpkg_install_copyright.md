# vcpkg_install_copyright

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/vcpkg_install_copyright.md).

Merges multiple copyright files into a single file and install it.
Installs a single copyright file.

## Usage

```cmake
vcpkg_install_copyright(FILE_LIST <file1> <file2>... [COMMENT])
```

## Parameters

### FILE_LIST
Specifies a list of license files with absolute paths. You must provide at least one file.

### COMMENT
This optional parameter adds a comment before at the top of the file. 

## Notes

This function creates a file called `copyright` inside `${CURRENT_PACKAGES_DIR}/share/${PORT}`

If more than one file is provided, this function concatenates the contents of multiple copyright files to a single file.

The resulting `copyright` file looks similar to this:

```
LICENSE-LGPL2.txt:

Lorem ipsum dolor...

LICENSE-MIT.txt:

Lorem ipsum dolor sit amet...
```

Or with `COMMENT`:

```
A meaningful comment

LICENSE-LGPL2.txt:

Lorem ipsum dolor...

LICENSE-MIT.txt:

Lorem ipsum dolor sit amet...
```

## Examples

```cmake
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE/license.md" "${SOURCE_PATH}/LICENSE/license_gpl.md" COMMENT "This is a comment")
```

You can also collect the required files using a `GLOB` pattern:

```cmake
file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
```

## Source

[vcpkg_install_copyright.md](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/vcpkg_install_copyright.cmake)
