# vcpkg remove

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/remove.md).**

## Synopsis

```no-highlight
vcpkg remove [options] <package>...
```

```no-highlight
vcpkg remove --outdated [options]
```

## Description

Remove port packages from Classic Mode.

`remove` removes listed packages and any packages that require them from the Classic Mode [installed directory](common-options.md#install-root). See the [install command documentation](install.md#package-syntax) for detailed syntax of the `<package>` parameter.

This command is not currently supported in [Manifest Mode][].

## Options

All vcpkg commands support a set of [common options](common-options.md).

### `--recurse`

Allow removing packages not specified on the command line.

By default, vcpkg refuses to execute a removal plan that would remove packages not listed on the command line.

### `--dry-run`

Print the packages to be removed, but do not remove them.

### `--outdated`

Remove all packages that do not match the available port versions.

For each installed package, vcpkg will compare the installed version string to the version string of the current recipe. If those versions differ, the package will be selected for removal. If `--outdated` is passed, no packages should be listed on the command line.

[Manifest Mode]: ../users/manifests.md
