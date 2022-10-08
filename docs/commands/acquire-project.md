# vcpkg acquire-project

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/acquire-project.md).**

**This command is part of the experimental feature, vcpkg-artifacts.**

## Synopsis
```no-highlight
vcpkg acquire-project [artifacts context options]
```

## Description

Downloads artifacts to the artifact cache specified in a vcpkg-configuration.json, without activating them.

## Example
```no-highlight
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
$ vcpkg acquire-project
warning: vcpkg-artifacts are experimental and may change at any time.
 Artifact                           Version    Status        Dependency  Summary
 microsoft:compilers/arm/gcc        2020.10.0  will install              GCC compiler for ARM CPUs.
 microsoft:tools/ninja-build/ninja  1.10.2     will install              Ninja is a small build system with a focus on speed.
```

## Options

All vcpkg commands support a set of [common options](common-options.md).

All unrecognized options are considered [artifacts context options](artifacts-context-options.md).

<a name="force"></a>

### `--force`

Acquires the indicated artifacts, even if they are already acquired.
