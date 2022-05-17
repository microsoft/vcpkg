# Common Command Options

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/common-options.md).**

All vcpkg commands accept a group of common options that control cross-cutting aspects of the tool.

<a name="triplet"></a>

## `--triplet=<triplet>`

Specify the target [architecture triplet][triplets].

If unset, defaults to the `VCPKG_DEFAULT_TRIPLET` environment variable. If that is unset, it is deduced based on the host architecture and operating system.

<a name="host-triplet"></a>

## `--host-triplet=<triplet>`

Specify the host [architecture triplet][triplets].

If unset, defaults to the `VCPKG_DEFAULT_HOST_TRIPLET` environment variable. If that is unset, it is deduced based on the host architecture and operating system.

<a name="overlay-ports"></a>

## `--overlay-ports=<path>`

Specify a directory to be considered for [overlay ports](../specifications/ports-overlay.md).

This option can be specified multiple times; ports will resolve to the first match.

<a name="overlay-triplets"></a>

## `--overlay-triplets=<path>`

Specify a directory to be considered for [overlay triplets](../examples/overlay-triplets-linux-dynamic.md).

This option can be specified multiple times; [triplets][] will resolve to the first match.

<a name="binarysource"></a>

## `--binarysource=<config>`

Add a source for [Binary Caching](../users/binarycaching.md).

This option can be specified multiple times; see the Binary Caching documentation for how multiple binary sources interact.

<a name="x-asset-sources"></a>

## `--x-asset-sources=<config>`

**Experimental: will change or be removed at any time**

Add a source for [Asset Caching](../users/assetcaching.md).

This option can be specified multiple times; see the Asset Caching documentation for how multiple binary sources interact.

## `--downloads-root=<path>`

Specify where downloaded tools and source code archives should be kept.

If unset, defaults to the `VCPKG_DOWNLOADS` environment variable. If that is unset, defaults to `downloads/` under the vcpkg root folder.

## `--vcpkg-root=<path>`

Specifies the vcpkg root folder.

This folder should be a valid vcpkg instance, such as a `git clone` of `https://github.com/microsoft/vcpkg`.

### `--x-manifest-root=<path>`

**Experimental: will change or be removed at any time**

Specifies the directory containing [`vcpkg.json`](../users/manifests.md).

Defaults to searching upwards from the current working directory.

## `--x-buildtrees-root=<path>`

**Experimental: will change or be removed at any time**

Specifies the temporary path to store intermediate build files, such as objects or unpacked source code.

If unset, defaults to `buildtrees/` under the vcpkg root folder.

## `--x-install-root=<path>`

**Experimental: will change or be removed at any time**

Specifies the path to lay out installed packages.

If unset in classic mode, defaults to `installed/` under the vcpkg root folder. If unset in manifest mode, defaults to `vcpkg_installed/` under the manifest folder.

## `--x-packages-root=<path>`

**Experimental: will change or be removed at any time**

Specifies the temporary path to stage intermediate package files before final install.

If unset, defaults to `packages/` under the vcpkg root folder.

## `--x-json`

**Experimental: will change or be removed at any time**

Requests structured JSON output from the command instead of human-readable output.

*Note: most commands do not currently respect this option.*

## Response Files (`@<file>`)

The vcpkg command line accepts text files containing newline-separated command line parameters.

The tool will act as though the items in the file were spliced into the command line in place of the `@` reference. Response files cannot contain additional response files.

[triplets]: ../users/triplets.md
