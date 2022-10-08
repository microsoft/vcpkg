# vcpkg acquire

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/acquire.md).**

**This command is part of the experimental feature, vcpkg-artifacts.**

## Synopsis
```no-highlight
vcpkg acquire [options] <artifact>...
```

## Description

Download artifacts to the artifact cache, without activating them.

## Example
```no-highlight
$ vcpkg acquire gcc
warning: vcpkg-artifacts are experimental and may change at any time.
 Artifact                     Version    Status        Dependency  Summary
 microsoft:compilers/arm/gcc  2020.10.0  will install              GCC compiler for ARM CPUs.

1 artifacts installed successfully
```

## Options

All vcpkg commands support a set of [common options](common-options.md).

All unrecognized options are considered [artifacts context options](artifacts-context-options.md).

### artifact

An artifact id or reference.

<a name="version"></a>

### `--version`

The requested version of the artifact to acquire. If this switch is used, there must be one switch per artifact listed.

<a name="force"></a>

### `--force`

Acquires the indicated artifacts, even if they are already acquired.
