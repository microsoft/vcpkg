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

Build and install port packages.

### Classic Mode

In Classic Mode, this verb adds port packages to the existing set in the [installed directory][] (defaults to `installed/` under the vcpkg root). This can require removing and rebuilding existing packages, which can fail.

<a id="package-syntax"></a>

**Package Syntax**
```
portname[feature1,feature2]:triplet
```

Package references without a triplet are automatically qualified by the [default target triplet](common-options.md#triplet). Package references that do not explicitly list `core` are considered to imply all default features.

### Manifest Mode

In [Manifest Mode][], this verb sets the [installed directory][] to the state specified by the `vcpkg.json` manifest file, adding, removing, or rebuilding packages as needed.

[installed directory]: common-options.md#install-root

## Options

All vcpkg commands support a set of [common options](common-options.md).

### `--allow-unsupported`

Instead of stopping on an unsupported port, continue with a warning.

By default, vcpkg refuses to execute an install plan containing a port installation for a triplet outside its [`"supports"`][supports] clause. The [`"supports"`][supports] clause of a package describes the full set of platforms a package is expected to be buildable on. This flag instructs vcpkg to warn that the build is expected to fail instead of stopping.

### `--clean-after-build`

Clean buildtrees, packages, and downloads after building each package.

This option has the same effect as passing [`--clean-buildtrees-after-build`](#clean-buildtrees-after-build), [`--clean-downloads-after-build`](#clean-downloads-after-build), and [`--clean-packages-after-build`](#clean-packages-after-build).

<a id="clean-buildtrees-after-build"></a>

### `--clean-buildtrees-after-build`

Clean all subdirectories from the buildtrees temporary subfolder after building each package.

All top-level files in the buildtrees subfolder (e.g. `buildtrees/zlib/config-x64-windows-out.log`) will be kept. All subdirectories will be deleted.

<a id="clean-downloads-after-build"></a>

### `--clean-downloads-after-build`

Clean all unextracted assets from the `downloads/` folder after building each package.

All top level files in the `downloads/` folder will be deleted. Extracted tools will be kept.

<a id="clean-packages-after-build"></a>

### `--clean-packages-after-build`

Clean the packages temporary subfolder after building each package.

The packages subfolder for the built package (for example, `packages/zlib_x64-windows`) will be deleted after installation.

### `--dry-run`

Print the install plan, but do not remove or install any packages.

The install plan lists all packages and features that will be installed, as well as any other packages that need to be removed and rebuilt.

<a id="editable"></a>

### `--editable`

**Classic Mode Only**

Perform editable builds for all directly referenced packages on the command line.

When vcpkg builds ports, it purges and re-extracts the source code each time to ensure inputs are accurately. This is necessary for [Manifest Mode][] to accurately update what is installed and [Binary Caching][] to ensure cached content is correct.

Passing the `--editable` flag disables this behavior, preserving edits to the extracted sources in the `buildtrees/` folder. This helps develop patches quickly by avoiding the need to write a file on each change.

Sources extracted during an editable build do not have a `.clean/` suffix on the directory name and will not be cleared by subsequent non-editable builds.

### `--enforce-port-checks`

Fail install if a port has detected problems or attempts to use a deprecated feature.

By default, vcpkg will run several checks on built packages and emit warnings if any issues are detected. This flag upgrades those warnings to an error.

<a name="feature"></a>

### `--x-feature=<feature>`

**Experimental and may change or be removed at any time**

**[Manifest Mode][] Only**

Specify an additional [feature](../users/manifests.md#features) from the `vcpkg.json` to install dependencies for.

By default, only [`"dependencies"`][dependencies] and the dependencies of the [`"default-features"`][default-features] will be installed.

### `--head`

**Classic Mode Only**

Request all packages explicitly referenced on the command line to fetch the latest sources available when building.

This flag is only intended for temporary testing and is not intended for production or long-term use. This disables [Binary Caching][] for all explicitly referenced packages and their dependents because vcpkg cannot accurately track all inputs.

### `--keep-going`

Continue the install plan after the first failure.

By default, vcpkg will stop at the first package build failure. This flag instructs vcpkg to continue building and installing other parts of the install plan that don't depend upon the failed package.

### `--x-no-default-features`

**Experimental and may change or be removed at any time**

**[Manifest Mode][] Only**

Don't install the default features from the top-level manifest.

When using `install` in Manifest Mode, by default all dependencies of the features listed in [`"default-features"`][default-features] will be installed. This flag disables that behavior so only features explicitly enabled by [`--x-feature`](#feature) will be installed.

### `--no-downloads`

When building a package, prevent ports from downloading new assets during the build.

By default, ports will acquire source code and tools on demand from the internet (subject to [Asset Caching][]). This parameter blocks downloads and restricts ports to only the assets that were previously downloaded and cached on the machine.

### `--only-downloads`

Attempt to download all assets required for an install plan without performing any builds.

When passed this option, vcpkg will run each build in the plan until it makes its first non-downloading external process call. Most ports perform all downloads before the first external process call (usually to their buildsystem), so this procedure will download all required assets. Ports that do not follow this procedure will not have their assets predownloaded.

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

<a id="write-nuget-packages-config"></a>

### `--x-write-nuget-packages-config`

**Experimental and may change or be removed at any time**

Writes out a NuGet `packages.config`-formatted file for use with [Binary Caching][].

This option can be used in conjunction with `--dry-run` to obtain the list of NuGet packages required from [Binary Caching][] without building or installing any packages. This enables the NuGet command line to be invoked separately for advanced scenarios, such as using alternate protocols to acquire the `.nupkg` files.

### `--no-print-usage`

Suppress generation of usage text printed at the end of installation.

[Asset Caching]: ../users/assetcaching.md
[Binary Caching]: ../users/binarycaching.md
[Manifest Mode]: ../users/manifests.md
[supports]: ../users/manifests.md#supports
[default-features]: ../users/manifests.md#default-features
[dependencies]: ../users/manifests.md#dependencies
