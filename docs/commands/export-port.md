# vcpkg export-port

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/export-port.md).**

## Synopsis
```no-highlight
vcpkg export-port <package-spec> <destination> [options]
```

## Description
Export a package's port files to a destination.

* **`<package-spec>`**: The most basic form of a package spec is a single port name. This command accepts non-qualified and version-qualified package specs.

    * The version-qualifier is an `@` (at sign) followed by a version identifier. Version identifiers consist of two parts, the version string and an optional numeric port-version separated by a `#` (number sign). Example: `1.0.0#1`, `2020-11-21#3`, `hello` (equivalent to `hello#0`). 
    
    * All spaces and special characters in a version identifier must be escaped by prefixing them with a `\` (forward slash). For example, `tag\:1"`. To make it easier to match dot-separated and date versions, the following characters are not required to be escaped: 
        * `.` (dot), 
        * `-` (hyphen), 
        * `+` (plus sign), and 
        * `_` (underscore). 

    * For legacy reasons, the `#` (number sign) character is never allowed as part of a version identifier to avoid ambiguity with the port-version delimiter. 

    This command has two modes of operation: un-versioned and versioned. 
    For un-versioned package specs, the exported port files correspond to the version of the port that Classic Mode installs.
    For version-qualified package specs, the port files corresponding to the version identifier are exported.

    Version-qualified package specs are looked up in the configured registry set. The `--no-registries` option can be passed to disable registry lookup.

* **`<destination>`**: The destination directory where the package's port files will be exported into, parent directories above the `destination` path will be created as necessary. By default, vcpkg will refuse to export to a directory that is not empty. The `--force` option forces vcpkg to export files to a non-empty directory, all existing files in `destination` will be deleted before exporting.

## Example
### Basic examples
```no-highlight
$vcpkg export zlib C:\overlay-ports\zlib
Port files have been exported to C:\overlay-ports\zlib
```

```no-highlight
$ vcpkg export-port fmt@8.1.1#2 C:\overlay-ports\fmt
Port files have been exported to C:\overlay-ports\fmt
```

### Advanced example
```no-highlight
# export version "hello $world" of library foo

$ vcpkg export-port 'foo@hello\\ \\\$world' C:\overlay-ports\foo
Port files have been exported to C:\overlay-ports\foo
```
Note the following things in the previous example:

* The package spec argument is enclosed in quotes (`'`) to avoid spliting it into two separate arguments (`foo@hello\\` and `\\\$world`).
* Escape sequences have their `\` (forward slashes) escaped, this is because terminals also use this character for their own escape sequences.
* The `$` dollar sign is itself escaped (`\$`). Otherwise shell expands `$world` as a variable.  

For vcpkg to match version "`hello $world`", all spaces and special characters in the version-qualifier need to be escaped. In other words, vcpkg needs to receive "`foo@hello\ \$world`" as its first argument's value. Review your terminal's documentation to determine which characters need to be escaped in your vcpkg invocation.

## Options
All vcpkg commands support a set of [common options](common-options.md).

### `--force`
Forces vcpkg to export port files to a non-empty directory, any existing files will be deleted before exporting.

### `--no-registries`
Disables looking up package names in registries.
