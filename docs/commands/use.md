# vcpkg use

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/use.md).**

**This command is part of the experimental feature, vcpkg-artifacts.**

## Synopsis
```no-highlight
vcpkg use <artifact>...
```

## Description

Activates a single artifact for use in the calling terminal.

## Example
```no-highlight
$ cmake
cmake: The term 'cmake' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
$ vcpkg use cmake
warning: vcpkg-artifacts are experimental and may change at any time.
 Artifact                       Version  Status     Dependency  Summary
 microsoft:tools/kitware/cmake  3.20.1   installed              Kitware's cmake tool

Activating individual artifacts
$ cmake
Usage

  cmake [options] <path-to-source>
  cmake [options] <path-to-existing-build>
  cmake [options] -S <path-to-source> -B <path-to-build>

Specify a source directory to (re-)generate a build system for it in the
current working directory.  Specify an existing build directory to
re-generate its build system.

Run 'cmake --help' for more information.
```

## Options

All vcpkg commands support a set of [common options](common-options.md).

All unrecognized options are considered [artifacts context options](artifacts-context-options.md).

<a name="version"></a>

### `--version`

The requested version of the artifact to acquire. If this switch is used, there must be one switch per artifact listed.

<a name="force"></a>

### `--force`

Acquires the indicated artifacts, even if they are already acquired.

<a name="msbuild-props"></a>

### `--msbuild-props path`

Generates a file at `path` which contains MSBuild activation context.
