# vcpkg x-update-baseline

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/update-baseline.md).**

**This command is experimental and may change or be removed at any time**

## Synopsis

```no-highlight
vcpkg x-update-baseline [options] [--add-initial-baseline] [--dry-run]
```

## Description

Update baselines for all configured [registries][].

In [Manifest Mode][], this command operates on all [registries][] in the `vcpkg.json` and the [`vcpkg-configuration.json`][vcj]. In Classic Mode, this command operates on the [`vcpkg-configuration.json`][vcj] in the vcpkg instance (`$VCPKG_ROOT`).

See the [versioning documentation](../users/versioning.md#baselines) for more information about baselines.

## Options

All vcpkg commands support a set of [common options](common-options.md).

### `--dry-run`

Print the planned baseline upgrades, but do not modify the files on disk.

<a id="add-initial-baseline"></a>

### `--add-initial-baseline`

**[Manifest Mode][] Only**

Add a [`"builtin-baseline"`][builtin-baseline] field to the `vcpkg.json` if it does not already have one.

Without this flag, it is an error to run this command on a manifest that does not have any [registries][] configured.

[Manifest Mode]: ../users/manifests.md
[builtin-baseline]: ../users/manifests.md#builtin-baseline
[vcj]: ../users/registries.md#vcpkg-configurationjson
[registries]: ../users/registries.md
