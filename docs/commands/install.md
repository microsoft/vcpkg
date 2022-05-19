# vcpkg install

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/install.md).**

## Synopsis

**Classic Mode**
```no-highlight
vcpkg install [options] <package>...
```

**Manifest Mode**
```no-highlight
vcpkg install [options]
```

## Description

Build and install packages.

### Classic Mode

In Classic Mode, this verb adds packages to the existing set in the installed directory. This may require rebuilding existing packages with new features.

**Package Syntax**
```
name[feature1,feature2]:triplet
```

Package references without a triplet are automatically qualified by the [default target triplet](common-options.md#triplet). Package references that do not explicitly list `core` are considered to imply all default features.

### Manifest Mode

In [Manifest Mode][], this verb sets the installed directory to the state specified by the manifest file, adding, removing, or rebuilding packages as needed.

## Options

All vcpkg commands support a set of [common options](common-options.md).

### `--allow-unsupported`

Instead of erroring on an unsupported port, continue with a warning.

By default, vcpkg refuses to execute an install plan containing a port installation for a triplet outside its [`"supports"`][] clause. This flag instructs vcpkg to ignore the [`"supports"`][] field.

### `--clean-after-build`

Clean buildtrees, packages, and downloads after building each package.

### `--clean-buildtrees-after-build`

Clean all subdirectories from the buildtrees temporary subfolder after building each package.

All top-level files in the buildtrees subfolder (e.g. `buildtrees/zlib/config-x64-windows-out.log`) will be kept.

### `--clean-downloads-after-build`

Clean all unextracted assets from the `downloads/` folder after building each package.

Extracted tools will be kept even with this flag.

### `--clean-packages-after-build`

Clean the packages temporary subfolder after building each package.

### `--dry-run`

Only print the install plan, do not remove or install any packages.

### `--editable`

**Classic Mode Only**

Perform editable builds for all directly referenced packages on the command line.

When vcpkg builds ports, it purges and re-extracts the source code each time to ensure inputs are accurately. This is necessary for [Manifest Mode][] to accurately update what is installed and [Binary Caching][] to ensure cached content is correct.

Passing the `--editable` flag disables this behavior, preserving edits to the extracted sources in the `buildtrees/` folder. This helps develop patches quickly by avoiding the need to write a file on each change.

Sources extracted during an editable build do not have a `.clean/` suffix on the directory name and will not be cleared by subsequent non-editable builds.

### `--enforce-port-checks`

Fail install if a port has detected problems or attempts to use a deprecated feature.

By default, vcpkg will run several checks on built packages and emit warnings if any issues are detected. This flag upgrades those warnings to an error.

### `--x-feature=<feature>`

**Experimental and may change or be removed at any time**

**[Manifest Mode][] Only**

Specify an additional feature from the `vcpkg.json` to install dependencies for.

### `--head`

**Classic Mode Only**

Request all packages explicitly referenced on the command line to fetch the latest sources available when building.

This flag is only intended for temporary testing and is not intended for production or long-term use. This disables [Binary Caching][] for all explicitly referenced packages and any packages built on them because vcpkg cannot accurately track all inputs.

### `--keep-going`

Continue the install plan after the first failure.

Without this flag, vcpkg will stop at the first package build failure. With this flag, vcpkg will continue to build and install other parts of the install plan that don't depend on the failed package.

### `--x-no-default-features`

**Experimental and may change or be removed at any time**

**[Manifest Mode][] Only**

Don't install the default features from the top-level manifest.

When using `install` in Manifest Mode, by default all dependencies of the features listed in [`"default-features"`][] will be installed. This flag disables that behavior so (without any `TODO` flags) only the dependencies listed in [`"dependencies"`][] will be installed.

### `--no-downloads`

When building a package, prevent ports from downloading new assets during the build.

By default, ports will acquire source code and tools on demand from the internet (subject to [Asset Caching][]). This parameter blocks downloads and restricts ports to only the assets that were previously downloaded and cached on the machine.

### `--only-downloads`

Attempt to download all assets required for an install plan without performing any builds.

When passed this option, vcpkg will run every recipe in the plan until they make their first non-downloading external process call. Most ports perform all required downloads before this call (which is usually to their buildsystem), so this procedure will successfully run all download steps without executing the underlying build.

### `--only-binarycaching`

Refuse to perform any builds. Only restore packages from [Binary Caches][Binary Caching].

This flag blocks vcpkg from performing builds on demand and will fail if a package cannot be found in any binary caches.

### `--recurse`

**Classic Mode Only**

Approve an install plan that requires rebuilding packages.

In order to modify the set of features of an installed package, vcpkg must remove and rebuild that package. Because this has the potential of failing and leaving the install tree with fewer packages than the user started with, the user must approve plans that rebuild packages by passing this flag.

### `--x-use-aria2`

**Experimental and may change or be removed at any time**

Use aria2 to perform download tasks.

<a id="x-write-nuget-packages-config"></a>

### `--x-write-nuget-packages-config`

**Experimental and may change or be removed at any time**

Writes out a NuGet `packages.config`-formatted file for use with [Binary Caching][].

This option can be used in conjunction with `--dry-run` to obtain the list of NuGet packages required from [Binary Caching][] without building or installing any packages. This enables the NuGet command line to be invoked separately for advanced scenarios, such as using alternate protocols to acquire the `.nupkg` files.

[Asset Caching]: ../users/assetcaching.md
[Binary Caching]: ../users/binarycaching.md
[Manifest Mode]: ../users/manifests.md
[`"supports"`]: ../users/manifests.md#supports
[`"default-features"`]: ../users/manifests.md#default-features
[`"dependencies"`]: ../users/manifests.md#dependencies
