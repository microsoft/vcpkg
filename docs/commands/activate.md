# vcpkg activate

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/activate.md).**

**This command is part of the experimental feature, vcpkg-artifacts.**

## Synopsis
```no-highlight
vcpkg activate [artifacts context options]
```

## Description

Downloads and activates artifacts in the calling terminal as specified by vcpkg-configuration.json.

## Example
```no-highlight
$ ninja --version
ninja: The term 'ninja' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
$ type .\vcpkg-configuration.json
{
  "default-registry": {
    "kind": "git",
    "baseline": "e2667a41fc2fc578474e9521d7eb90b769569c83",
    "repository": "https://github.com/microsoft/vcpkg"
  },
  "registries": [
    {
      "kind": "artifact",
      "location": "https://aka.ms/vcpkg-ce-default",
      "name": "microsoft"
    }
  ],
  "requires": {
    "microsoft:compilers/arm/gcc": "* 2020.10.0",
    "microsoft:tools/ninja-build/ninja": "* 1.10.2"
  }
}
$ vcpkg activate
warning: vcpkg-artifacts are experimental and may change at any time.
 Artifact                           Version    Status     Dependency  Summary
 microsoft:compilers/arm/gcc        2020.10.0  installed              GCC compiler for ARM CPUs.
 microsoft:tools/ninja-build/ninja  1.10.2     installed              Ninja is a small build system with a focus on speed.

Project c:\Dev\test activated
$ ninja --version
1.10.2
```

## Options

All vcpkg commands support a set of [common options](common-options.md).

All unrecognized options are considered [artifacts context options](artifacts-context-options.md).

<a name="force"></a>

### `--force`

Acquires the indicated artifacts, even if they are already acquired.

<a name="msbuild-props"></a>

### `--msbuild-props path`

Generates a file at `path` which contains MSBuild activation context.

<a name="json"></a>

### `--json path`

Generates a file at `path` which contains the activation context that is being set on the terminal.
