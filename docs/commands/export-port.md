# vcpkg x-export-port

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/export-port.md).**

## Synopsis
```no-highlight
vcpkg x-export-port <package-spec> <destination> [options]
```

## Description
Export a package's port files to a destination.

* **`<package-spec>`**: The package to export, optionally accepts a version-qualifier to export a specific port version.

    * The version-qualifier is an `@` (at sign) followed by a version identifier. Version identifiers consist of two parts, the version string and an optional numeric port-version separated by a `#` (number sign). Example: `1.0.0#1`, `2020-11-21#3`, `hello` (equivalent to `hello#0`). 
    
    * All spaces and special characters in a version identifier must be escaped by prefixing them with a `\` (backslash). To make it easier to match dot-separated and date versions, the following characters *don't require* escaping: 
        * `.` (dot), 
        * `-` (hyphen), 
        * `+` (plus sign), and 
        * `_` (underscore). 

    * For legacy reasons, the `#` (number sign) character is never allowed as part of a version identifier, even if escaped.

    This command has different behavior depending on whether any [registries](../users/registries.md) are configured.

    If no registries are configured, all ports resolve to the builtin-registry. Un-versioned packages, resolve the same as Classic Mode's `install` command.

    If registries are configured, the package is [resolved to a registry](../users/registries.md#package-name-resolution). If no version is passed, the baseline version of the port is exported.

    The `--no-registries` option can be passed to disable registry lookup.

    |                 | **No registries**         | **Has registries**        |
    |-----------------|---------------------------|---------------------------|
    | **No version**  | Classic Mode version      | Registry baseline version |
    | **Has version** | Built-in registry version | Registry version          |

* **`<destination>`**: The destination directory for the exported port files.

    Parent directories above the `destination` path are created as necessary. By default, vcpkg refuses to export to a non-empty directory. The `--force` option removes all existing files at the `destination` before exporting.

## Example
### Basic examples
```no-highlight
$ vcpkg x-export-port zlib overlay-ports/zlib
Port files have been exported to /home/vcpkg/overlay-ports/zlib
```

```no-highlight
$ vcpkg x-export-port fmt@8.1.1#2 /overlay-ports/fmt
Port files have been exported to /home/vcpkg/overlay-ports/fmt
```

### Advanced example
```no-highlight
# export version 'hello $world' of library foo

$ vcpkg x-export-port 'foo@hello\\ \\\$world' /overlay-ports/foo
Port files have been exported to /home/vcpkg/overlay-ports/foo
```
Note the following things on this example:

* The package spec argument is enclosed in quotes (`'`) to avoid spliting it into two separate arguments (`foo@hello\\` and `\\\$world`).

* Escape sequences have their `\` (backslashes) escaped, this is because some terminals also use this character for their own escape sequences.
* The `$` dollar sign is itself escaped (`\$`). Otherwise shell expands `$world` as a variable.  

For vcpkg to match version "`hello $world`", all spaces and special characters in the version-qualifier need to be escaped. In other words, vcpkg needs to receive "`foo@hello\ \$world`" as its first argument's value. Review your terminal's documentation to determine which characters need to be escaped in your vcpkg invocation.

## Options
All vcpkg commands support a set of [common options](common-options.md).

### `--force`
Forces vcpkg to export port files to a non-empty directory, any existing files will be deleted before exporting.

### `--no-registries`
Disables name lookup in registries. All package names are resolved to the built-in registry instead.

### `--subdir`
Extract port files in a subdirectory in the destination. The subdirectory's name corresponds to the package's name.
