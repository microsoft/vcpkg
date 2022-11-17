# Common Command Options

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/common-options.md).**

Most vcpkg commands accept a group of common options that control cross-cutting aspects of the tool. Not all options affect every command. For example, a command that does not download any files will be unaffected by changing the downloads directory.

<a name="asset-sources"></a>

## `--x-asset-sources=<config>`

**Experimental: will change or be removed at any time**

Specify the cache configuration for [Asset Caching](../users/assetcaching.md).

<a name="binarysource"></a>

## `--binarysource=<config>`

Add a source for [Binary Caching](../users/binarycaching.md).

This option can be specified multiple times; see the Binary Caching documentation for how multiple binary sources interact.

<a name="buildtrees-root"></a>

## `--x-buildtrees-root=<path>`

**Experimental: will change or be removed at any time**

Specifies the temporary path to store intermediate build files, such as objects or unpacked source code.

Defaults to `buildtrees/` under the vcpkg root folder.

<a name="downloads-root"></a>

## `--downloads-root=<path>`

Specify where downloaded tools and source code archives should be kept.

Defaults to the `VCPKG_DOWNLOADS` environment variable. If that is unset, defaults to `downloads/` under the vcpkg root folder.

<a name="host-triplet"></a>

## `--host-triplet=<triplet>`

Specify the host [architecture triplet][triplets].

Defaults to the `VCPKG_DEFAULT_HOST_TRIPLET` environment variable. If that is unset, deduced based on the host architecture and operating system.

<a name="install-root"></a>

## `--x-install-root=<path>`

**Experimental: will change or be removed at any time**

Specifies the path to lay out installed packages.

In Classic Mode, defaults to `installed/` under the vcpkg root folder.

In [Manifest Mode](../users/manifests.md), defaults to `vcpkg_installed/` under the manifest folder.

<a name="manifest-root"></a>

## `--x-manifest-root=<path>`

**Experimental: will change or be removed at any time**

Specifies the directory containing [`vcpkg.json`](../users/manifests.md).

Defaults to searching upwards from the current working directory for the nearest `vcpkg.json`.

<a name="overlay-ports"></a>

## `--overlay-ports=<path>`

Specifies a directory containing [overlay ports](../specifications/ports-overlay.md).

This option can be specified multiple times; ports will resolve to the first match.

<a name="overlay-triplets"></a>

## `--overlay-triplets=<path>`

Specifies a directory containing [overlay triplets](../examples/overlay-triplets-linux-dynamic.md).

This option can be specified multiple times; [triplets][] will resolve to the first match.

<a name="packages-root"></a>

## `--x-packages-root=<path>`

**Experimental: will change or be removed at any time**

Specifies the temporary path to stage intermediate package files before final install.

Defaults to `packages/` under the vcpkg root folder.

<a name="triplet"></a>

## `--triplet=<triplet>`

Specify the target [architecture triplet][triplets].

Defaults to the `VCPKG_DEFAULT_TRIPLET` environment variable. If that is unset, deduced based on the host architecture and operating system.

Note that on Windows operating systems, the architecture is always deduced as x86 for legacy reasons.

<a name="vcpkg-root"></a>

## `--vcpkg-root=<path>`

Specifies the vcpkg root folder.

Defaults to the directory containing the vcpkg program. The directory must be a valid vcpkg instance, such as a `git clone` of `https://github.com/microsoft/vcpkg`. This option can be used to run a custom-built copy of the tool directly from the build folder.

## Response Files (`@<file>`)

The vcpkg command line accepts text files containing newline-separated command line parameters.

The tool will act as though the items in the file were spliced into the command line in place of the `@` reference. Response files cannot contain additional response files.

[triplets]: ../users/triplets.md
