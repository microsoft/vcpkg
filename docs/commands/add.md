# vcpkg add

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/add.md).**

**This command is part of the experimental feature, vcpkg-artifacts.**

## Synopsis
```no-highlight
vcpkg add artifact <artifact>...

vcpkg add port <port> <port options>...
```

## Description

Adds a new artifact or port dependency reference to a manifest.

## Example
```no-highlight
$ type vcpkg.json
{}
$ type vcpkg-configuration.json
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
  ]
}
$ vcpkg add port zlib
Succeeded in adding ports to vcpkg.json file.
$ vcpkg add artifact gcc
warning: vcpkg-artifacts are experimental and may change at any time.
 Artifact                     Version    Status     Dependency  Summary
 microsoft:compilers/arm/gcc  2020.10.0  installed              GCC compiler for ARM CPUs.

Run `vcpkg activate` to apply to the current terminal
$ type vcpkg.json
{
  "dependencies": [
    "zlib"
  ]
}
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
    "microsoft:compilers/arm/gcc": "* 2020.10.0"
  }
}
```

## Options

All vcpkg commands support a set of [common options](common-options.md).
