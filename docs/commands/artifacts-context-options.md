# Artifacts Context Options

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/artifacts-context-options.md).**

Many vcpkg-artifacts commands accept an arbitrary number of extra arguments which control resolving which artifacts are used, usually for selecting the correct host or target architecture.

<a name="windows"></a>

## `--windows`

Indicates that the host is a Windows system. Causes the constant `windows` to become true in demands.

<a name="osx"></a>

## `--osx`

Indicates that the host is a MacOS / osx system. Causes the constant `osx` to become true in demands.

<a name="linux"></a>

## `--linux`

Indicates that the host is a Linux system. Causes the constant `linux` to become true in demands.

<a name="freebsd"></a>

## `--freebsd`

Indicates that the host is a FreeBSD system. Causes the constant `freebsd` to become true in demands.

<a name="x64"></a>

## `--x64`

Indicates that the host is an x64 / amd64 system. Causes the constant `x64` to become true in demands.

<a name="x86"></a>

## `--x86`

Indicates that the host is an x86 system. Causes the constant `x86` to become true in demands.

<a name="arm"></a>

## `--arm`

Indicates that the host is an arm system. Causes the constant `arm` to become true in demands.

<a name="arm64"></a>

## `--arm64`

Indicates that the host is an arm64 system. Causes the constant `arm64` to become true in demands.

<a name="otherwise"></a>

## `--anything value`

Causes the constant `anything:value` to become true in demands. Note that `anything` can be anything. For example:

```no-highlight
$ type .\vcpkg-configuration.json
{
  "default-registry": { /* ... */ },
  "registries": [ /* ... */ ],
  "demands": {
    "example:hello": {
      "error": "example:hello matched"
    },
    "example:world and x86": {
      "error": "example:world and x86 matched"
    },
    "example:world and x64": {
      "error": "example:world and x64 matched"
    },
    "arm": {
      "error": "arm matched"
    }
  }
}
$ vcpkg activate --example hello
warning: vcpkg-artifacts are experimental and may change at any time.
ERROR: c:\Dev\test\vcpkg-configuration.json - example:hello matched
$ vcpkg activate --example world
warning: vcpkg-artifacts are experimental and may change at any time.
ERROR: c:\Dev\test\vcpkg-configuration.json - example:world & x64 matched
$ vcpkg activate --example world --x86
warning: vcpkg-artifacts are experimental and may change at any time.
ERROR: c:\Dev\test\vcpkg-configuration.json - example:world & x86 matched
$ vcpkg activate --arm
warning: vcpkg-artifacts are experimental and may change at any time.
ERROR: c:\Dev\test\vcpkg-configuration.json - arm matched
```
