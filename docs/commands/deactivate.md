# vcpkg deactivate

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/deactivate.md).**

**This command is part of the experimental feature, vcpkg-artifacts.**

## Synopsis
```no-highlight
vcpkg deactivate
```

## Description

Undoes any terminal manipulation previously performed by a call to `activate`.

## Example
```no-highlight
$ type .\vcpkg-configuration.json
{
  "default-registry": { /* ... */ },
  "registries": [  /* ... */ ],
  "requires": {
    "microsoft:tools/kitware/cmake": "* 3.20.1",
    "microsoft:tools/ninja-build/ninja": "* 1.10.2"
  }
}
$ cmake
cmake: The term 'cmake' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
$ ninja
ninja: The term 'ninja' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
$ vcpkg activate
warning: vcpkg-artifacts are experimental and may change at any time.
 Artifact                           Version  Status     Dependency  Summary
 microsoft:tools/kitware/cmake      3.20.1   installed              Kitware's cmake tool
 microsoft:tools/ninja-build/ninja  1.10.2   installed              Ninja is a small build system with a focus on speed.

Project c:\Dev\test activated
$ cmake
Usage

  cmake [options] <path-to-source>
  cmake [options] <path-to-existing-build>
  cmake [options] -S <path-to-source> -B <path-to-build>

Specify a source directory to (re-)generate a build system for it in the
current working directory.  Specify an existing build directory to
re-generate its build system.

Run 'cmake --help' for more information.

$ ninja
ninja: error: loading 'build.ninja': The system cannot find the file specified.

$ vcpkg deactivate
warning: vcpkg-artifacts are experimental and may change at any time.
Deactivating project c:\Dev\test\vcpkg-configuration.json
$ cmake
cmake: The term 'cmake' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
$ ninja
ninja: The term 'ninja' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
```

## Options

All vcpkg commands support a set of [common options](common-options.md).
