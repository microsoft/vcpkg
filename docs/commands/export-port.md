# vcpkg export-port

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/export-port.md).**

## Synopsis
```no-highlight
vcpkg export-port [options] <package> [version] <destination>
```

## Description
Export a package's port files to a destination.

### Classic Mode
In Classic Mode, this command exports the port files for a package in the built-in vcpkg catalog to a destination. 

By default, the exported files will be copied into a subdirectory named after the package in the destination, parent directories will be created as necessary. 

Unless a version is specified, this command will copy the package's port files currently on disk. 

The version argument can be passed to export the port files for a specific version of the package. A port version can be specified using the syntax `{version}#{port version}`. For example,  `8.1.1#2` means version `8.1.1` with port version `2`.

### Manifest Mode
This command is not available in manifest mode.

## Example
```no-highlight
$ vcpkg export-port fmt 8.1.1#2 ~/overlay-ports
Port files have been exported to /home/user/overlay-ports/fmt
```

## Options
All vcpkg commands support a set of [common options](common-options.md).

### `--add-version-suffix`
Add the exported version as suffix to the exported subdirectory's name.

This option is ignored if no version argument is passed or if the `--no-subdir` option is passed. 

### `--force`
vcpkg will refuse to export a package if the export destination is not empty. This option will make vcpkg remove all existing files in the destination before exporting.

### `--no-subdir`
Copies the package's port files directly into destination without creating a subdirectory for the package.
