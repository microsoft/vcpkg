# vcpkg export

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/commands/export.md).**

## Synopsis

```no-highlight
vcpkg export [options] <package>...
```

## Description

Export built packages from the [installed directory](common-options.md#install-root) into a standalone developer SDK.

`export` produces a standalone, distributable SDK (Software Development Kit) that can be used on another machine without separately acquiring vcpkg. It contains:

1. The prebuilt binaries for the selected packages
2. Their transitive dependencies
3. [Integration files](#standard-integration), such as a [CMake toolchain][cmake] or [MSBuild props/targets][msbuild].

`export` must be used from Classic Mode. [Manifest Mode](../users/manifests.md) is unsupported.

### Standard Integration

Most export formats contain a standard set of integration files:

- A [CMake toolchain][cmake] at `/scripts/buildsystems/vcpkg.cmake`
- [msbuild props/targets][msbuild] at `/scripts/buildsystems/msbuild/vcpkg.props` and `/scripts/buildsystems/msbuild/vcpkg.targets`.

Some export formats differ from this standard set; see the individual format help below for more details.

### Formats

Officially supported SDK formats:
- [Raw Directory](#raw-directory)
- [Zip](#zip)
- [7zip](#7zip)
- [NuGet](#nuget)

Experimental SDK formats (may change or be removed at any time):
- IFW
- Chocolatey
- Prefab
- Maven

#### Raw Directory

```no-highlight
vcpkg export --raw <package>...
```

Create an uncompressed directory layout at `<output-dir>/<output>/`.

Contains the [Standard Integration Files][].

See [`--output`][output] and [`--output-dir`][output-dir].

#### Zip

```no-highlight
vcpkg export --zip <package>...
```

Create a zip compressed directory layout at `<output-dir>/<output>.zip`.

Contains the [Standard Integration Files][].

See [`--output`][output] and [`--output-dir`][output-dir].

#### 7Zip

```no-highlight
vcpkg export --7zip <package>...
```

Create a 7zip directory layout at `<output-dir>/<output>.7z`.

Contains the [Standard Integration Files][].

See [`--output`][output] and [`--output-dir`][output-dir].

#### NuGet

```no-highlight
vcpkg export --nuget [--nuget-id=...] [--nuget-version=...] [--nuget-description=...] <package>...
```

Create an [NuGet](https://learn.microsoft.com/en-us/nuget/what-is-nuget) package at `<output-dir>/<nuget-id>.<nuget-version>.nupkg`.

Contains the [Standard Integration Files][] as well as additional MSBuild integration to support inclusion in an MSBuild C++ project (`.vcxproj`) via the NuGet Package Manager. Note that you cannot mix multiple NuGet packages produced with `export` together -- only one of the packages will be used. To add additional libraries, you must create a new export with the full set of dependencies.

See [`--nuget-id`](#nuget-id), [`--nuget-version`](#nuget-version), [`--nuget-description`](#nuget-description), [`--output`](#output), and [`--output-dir`](#output-dir).

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

[cmake]: ../users/buildsystems/cmake-integration.md
[msbuild]: ../users/buildsystems/msbuild-integration.md
[Standard Integration Files]: #standard-integration
