# vcpkg export

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/export.md).**

## Synopsis

```no-highlight
vcpkg export [options] {<package>... | --x-all-installed}
```

## Description

Export built packages from the [installed directory](common-options.md#install-root) into a standalone developer SDK.

`export` produces a standalone, distributable SDK (Software Development Kit) that can be used on another machine without separately acquiring vcpkg. It contains:

1. The prebuilt binaries for the selected packages
2. Their transitive dependencies
3. [Integration files](#standard-integration), such as a [CMake toolchain][cmake] or [MSBuild props/targets][msbuild]

`export` must be used from Classic Mode. [Manifest Mode](../users/manifests.md) is unsupported.

### Standard Integration

Most export formats contain a standard set of integration files:

- A [CMake toolchain][cmake] at `/scripts/buildsystems/vcpkg.cmake`
- [MSBuild props/targets][msbuild] at `/scripts/buildsystems/msbuild/vcpkg.props` and `/scripts/buildsystems/msbuild/vcpkg.targets`

Some export formats differ from this standard set; see the individual format help below for more details.

### Formats

Officially supported SDK formats:
- [Raw Directory](#raw-directory)
- [Zip](#zip)
- [7zip](#7zip)
- [NuGet](#nuget)

Experimental SDK formats (may change or be removed at any time):
- [IFW](#ifw)
- [Chocolatey](#chocolatey)
- [Prefab](#prefab)

#### Raw Directory

```no-highlight
vcpkg export --raw [options] <package>...
```

Create an uncompressed directory layout at `<output-dir>/<output>/`.

Contains the [Standard Integration Files][].

#### Zip

```no-highlight
vcpkg export --zip [options] <package>...
```

Create a zip compressed directory layout at `<output-dir>/<output>.zip`.

Contains the [Standard Integration Files][].

#### 7Zip

```no-highlight
vcpkg export --7zip [options] <package>...
```

Create a 7zip directory layout at `<output-dir>/<output>.7z`.

Contains the [Standard Integration Files][].

#### NuGet

```no-highlight
vcpkg export --nuget [options] <package>...
```

Create an [NuGet](https://learn.microsoft.com/en-us/nuget/what-is-nuget) package at `<output-dir>/<nuget-id>.<nuget-version>.nupkg`.

Contains the [Standard Integration Files][] as well as additional MSBuild integration to support inclusion in an MSBuild C++ project (`.vcxproj`) via the NuGet Package Manager. Note that you cannot mix multiple NuGet packages produced with `export` together -- only one of the packages will be used. To add additional libraries, you must create a new export with the full set of dependencies.

See also:
- [`--nuget-id`](#nuget-id)
- [`--nuget-version`](#nuget-version)
- [`--nuget-description`](#nuget-description)

#### IFW

**This export type is experimental and may change or be removed at any time**

```no-highlight
vcpkg export --ifw [options] <package>...
```

Export to an IFW-based installer.

See also:
- [`--ifw-configuration-file-path`](#ifw-configuration-file-path)
- [`--ifw-installer-file-path`](#ifw-installer-file-path)
- [`--ifw-packages-directory-path`](#ifw-packages-directory-path)
- [`--ifw-repository-directory-path`](#ifw-repository-directory-path)
- [`--ifw-repository-url`](#ifw-repository-url)

#### Chocolatey

**This export type is experimental and may change or be removed at any time**

```no-highlight
vcpkg export --x-chocolatey [options] <package>...
```

Export a Chocolatey package.

See also:
- [`--x-maintainer`](#maintainer)
- [`--x-version-suffix`](#version-suffix)

#### Prefab

**This export type is experimental and may change or be removed at any time**

```no-highlight
vcpkg export --prefab [options] <package>...
```

Export to Prefab format.

See also:
- [`--prefab-artifact-id`](#prefab-artifact-id)
- [`--prefab-group-id`](#prefab-group-id)
- [`--prefab-maven`](#prefab-maven)
- [`--prefab-min-sdk`](#prefab-min-sdk)
- [`--prefab-target-sdk`](#prefab-target-sdk)
- [`--prefab-version`](#prefab-version)

## Options

All vcpkg commands support a set of [common options](common-options.md).

### `<package>`

This is the list of top-level built packages which will be included in the SDK. Any dependencies of these packages will also be included to ensure the resulting SDK is self-contained.

<a id="package-syntax"></a>

**Package Syntax**
```
portname:triplet
```
Package references without a triplet are automatically qualified by the [default target triplet](common-options.md#triplet).

<a id="all-installed"></a>

### `--x-all-installed`

**This option is experimental and may change or be removed at any time**

Export all installed packages.

<a id="dry-run"></a>

### `--dry-run`

Do not perform the export, only print the export plan.

<a id="ifw-configuration-file-path"></a>

### `--ifw-configuration-file-path=`

Specify the temporary file path for the installer configuration.

<a id="ifw-installer-file-path"></a>

### `--ifw-installer-file-path=`

Specify the file path for the exported installer.

<a id="ifw-packages-directory-path"></a>

### `--ifw-packages-directory-path=`

Specify the temporary directory path for the repacked packages.

<a id="ifw-repository-directory-path"></a>

### `--ifw-repository-directory-path=`

Specify the directory path for the exported repository.

<a id="ifw-repository-url"></a>

### `--ifw-repository-url=`

Specify the remote repository URL for the online installer.

<a id="maintainer"></a>

### `--x-maintainer=`

Specify the maintainer for the exported Chocolatey package.

<a id="nuget-description"></a>

### `--nuget-description=`

Specifies the output description for [NuGet](#nuget) nupkgs.

Defaults to "Vcpkg NuGet export".

<a id="nuget-id"></a>

### `--nuget-id=`

Specifies the output id for [NuGet](#nuget) nupkgs.

This option overrides the [`--output`](#output) option specifically for the NuGet exporter. See `--output` for default values.

<a id="nuget-version"></a>

### `--nuget-version=`

Specifies the output version for [NuGet](#nuget) nupkgs.

Defaults to `1.0.0`.

<a id="output"></a>

### `--output=`

Specifies the output base name.

Each SDK type uses this base name to determine its specific output files. See the SDK-specific documentation above for details.

Defaults to `vcpkg-export-<date>-<time>`. Scripted use of `export` should always pass this flag to ensure deterministic output.

<a id="output-dir"></a>

### `--output-dir=`

Specifies the output directory.

All top-level SDK files will be produced into this directory. Defaults to the [vcpkg root directory](../users/config-environment.md#vcpkg_root).

<a id="prefab-artifact-id"></a>

### `--prefab-artifact-id=`

Artifact Id is the name of the project according to maven specifications.

<a id="prefab-group-id"></a>

### `--prefab-group-id=`

GroupId uniquely identifies your project according to maven specifications.

<a id="prefab-maven"></a>

### `--prefab-maven`

Enable maven.

<a id="prefab-min-sdk"></a>

### `--prefab-min-sdk=`

Android minimum supported sdk version.

<a id="prefab-target-sdk"></a>

### `--prefab-target-sdk=`

Android target supported sdk version.

<a id="prefab-version"></a>

### `--prefab-version=`

Version is the version of the project according to maven specifications.

<a id="version-suffix"></a>

### `--x-version-suffix=`

Specify the version suffix to add for the exported Chocolatey package.

[cmake]: ../users/buildsystems/cmake-integration.md
[msbuild]: ../users/buildsystems/msbuild-integration.md
[Standard Integration Files]: #standard-integration
