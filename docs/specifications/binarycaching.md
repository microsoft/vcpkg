# Binary Caching v1.1 (Jul 14, 2020)

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

**Up-to-date documentation is available at [Binarycaching](../users/binarycaching.md).**

## Motivation

The primary motivation of binary caching is to accelerate two broad scenarios in an easily accessible way

- Continuous Integration

- Developer Environment Changes (first-time or branch change)

We generally believe both of these scenarios are addressed with the same feature set, however when differences arise they will be discussed in the individual scenarios. 

It should also be explicitly noted that this specification does not intend to propose a "Microsoft Sanctioned Public Binaries Service" such as nuget.org – we only intend to enable users to leverage services they already have access to, such as GitHub, local file shares, Azure Artifacts, etc.

## Key User Stories

### CI -> CI

In this story, a CI build using either persistent or non-persistent machines wants to potentially reuse binaries built in a previous run of the pipeline. This is partially covered by the Cache tasks in GitHub Actions or Azure DevOps Pipelines, however the Cache task is all-or-nothing: a single package change will prevent restoration and require rebuilding the entire graph which is unacceptable in many scenarios (such as if actively developing one of the packages).

### CI -> Developer

In this story, the developer wants to reuse binaries built during a CI run. Given appropriate CI coverage, most developers will always have any needed dependencies pre-built by the CI system.

Notably, this scenario indicates a need for Read/Write access granularity on the remote storage solution. Developers should not need write access to the output from the CI system for security reasons.

### Single Developer (same machine reuse)

With the introduction of manifest files, each project will have separate instances of Vcpkg. The performance costs of rebuilding binaries across each cloned project can be debilitating for those working in micro-repos or open source; for the monolithic enterprise developer it is simply frustrating.

User-wide binary caching alleviates the pain of this scenario by ensuring the same binaries aren’t built multiple times (as long as the projects truly overlap with respect to versions/packages/etc).

### Developer <-> Developer (multi-machine / team scenario)

In a small team scenario, it's reasonable that multiple developer machines can trust each other enough to share binaries. This also applies to developers that have multiple machines and wish to share binaries between them (given a similar enough environment).

## Solution Aspects

### Tracking Compilers

In order to provide reliable binary caching, vcpkg must determine if the produced binaries are appropriate for the current context. Currently, we consider many factors, including:

- All files in the port directory

- The toolchain file contents

- The triplet contents

- All dependency binaries

- The version of the CMake tool used to build

and a few others.

However, we notably do not currently track the compiler used. This is critical for all cross-machine scenarios, as the environment is likely to change incompatibly from machine to machine. We propose hashing the compiler that will used by CMake. This can be accomplished either by reimplementing the logic of CMake or running some partial project and extracting the results. For performance reasons, we will prefer first using heuristics to approximate the CMake logic with accompanying documentation for users that fall outside those bounds.

Another aspect of the environment we don't currently track is the CRT version on Linux systems. Currently, we believe this will not cause as many problems in most practices (thus not suitable for an MVP), since the compiler will (generally) link against the system CRT and should sufficiently reflect any differences. This can also be easily worked around by the user with documentation – the toolchain file can simply have a comment such as "# this uses muslc", which will cause it to hash differently.

### Better control over source modifications

Currently, vcpkg caches sources inside `buildtrees/$PORT/src/`. The built-in helpers, such as `vcpkg_extract_archive_ex()` assume that if the appropriately named source folder exists, it is true, accurate, and without modification.

However, the basic workflow for working on ports (specifically, developing patches) breaks this assumption by directly editing whatever extracted source directory the tool is currently using until a successful build is achieved. The user then usually builds a patch file from their changes, then checks it in to the port directory (adding the changes to one of the tracked locations above) and everything is restored to normal.

However, this causes serious issues with the current tracking system, because modifications to this cached source are not detected and tracked into the binary package.

Our proposed solution is to force source re-extraction each time during builds that have uploading to any protocol enabled. Uploading/downloading can then be disabled on the command line via the --editable switch to reuse extracted sources and enable the current workflow.

### Protocols

To service different scenarios and user requirements, we need to support multiple backends. Currently, our CI system uses our only implemented backend: file-based archives.

#### Backend #1: File-Based Archives

This backend simply stores .zip files in a hierarchy similar to git objects: `$VCPKG_ROOT/archives/$XX/$YYYY.zip` with `$XX` being the first two characters of the computed package hash, and `$YYYY` being the full expanded hash. It also supports storing failure logs as `$VCPKG_ROOT/archives/fail/$XX/$YYYY.zip`, however we consider this an internal feature that is not relevant to the key User Stories.

Our CI system uses this backend by symlinking this directory to an Azure Files share, enabling built binaries and failure logs to be shared by all machines in the pool. Credentials are handled at the time of mounting the Azure Files share, so this does not require interactive authentication.

This protocol is ideal due to simplicity for same-machine reuse and simple serverless scenarios such as using networked SMB folders across multiple machines for very small teams. However, it has three significant limitations in the current incarnation:

- It uses the hardcoded directory `$VCPKG_ROOT/archives` (redirectable using symlinks, but unwieldy)

- It cannot use multiple directories

- There is no ability to treat directories as "read-only"/immutable

These second two points are required to implement the very useful concept of "fallback" folders (see https://github.com/NuGet/Home/wiki/%5BSpec%5D-Fallback-package-folders for NuGet’s spec on this topic).

#### Backend #2: NuGet (Azure DevOps Artifacts, GitHub Packages, etc)

This backend packages binaries into a "raw" NuGet package (not suitable for direct import by MSBuild projects) and uploads them to supported NuGet servers such as Azure DevOps Artifacts and GitHub Packages. We believe this will best satisfy the CI scenarios – both CI -> CI as well as CI -> Developer by relying on powerful, centralized, managed hosting.

There is a difference in this case between the developer and CI scenarios. The developer generally wants to configure their remotes for the project and then be able to run vcpkg commands as normal, with packages automatically being downloaded and uploaded to optimize the experience. This is similar to File-Based Archives.

While a CI system could use the same workflow as a developer, there are a few key differences. First, a CI system must use a stored secret for authentication, because it cannot interactively authenticate. Second, to enable more complex interactions with systems such as package signing and task-based restores, we must also support a 4-step workflow:

1. Vcpkg computes hashes of any potentially required packages and writes them to a file

2. An unspecified service/task/etc can parse this file and download any appropriate packages

3. vcpkg is then invoked a second time, with any downloaded packages. This consumes the packages, performs any installations and builds, and potentially produces new packages to an output folder.

4. Finally, another unspecified service/task/etc can take these output packages, sign them, and upload them.

This flow enables arbitrarily complex, user-defined authentication and signing schemes, such as the tasks provided by GitHub Actions and Azure DevOps Pipelines or manual signing as documented in the NuGet documentation: https://docs.microsoft.com/en-us/nuget/create-packages/sign-a-package.

#### Configuration

Currently, our file-based backend is enabled by passing the undocumented `--binarycaching` flag to any Vcpkg command or setting the undocumented environment variable `VCPKG_FEATURE_FLAGS` to `binarycaching`. We will replace this feature flag with an on-by-default user-wide behavior, plus command line and environment-based configurability.

The on-by-default configuration will specify the file-based archive protocol on either `%LOCALAPPDATA%/vcpkg/archives` (Windows) or `$XDG_CACHE_HOME/vcpkg/archives` (Unix). If `XDG_CACHE_HOME` is not defined on Unix, we will fall back to `$HOME/.cache/vcpkg/archives` based on the [XDG Base Directory Specification][1]. This can be redirected with a symlink, or completely overridden with the command line or environment. In the future we can also consider having a user-wide configuration file, however we do not believe this is important for any of our key scenarios.

On the command line, a backend can be specified via `--binarysource=<config>`. Multiple backends can be specified by passing the option multiple times and the order of evaluation is determined by the order on the command line. Writes will be performed on all upload backends, but only for packages that were built as part of this build (the tool will not repackage/reupload binaries downloaded from other sources).

The environment variable `VCPKG_BINARY_SOURCES` can be set to a semicolon-delimited list of `<config>`. Empty `<config>` strings are valid and ignored, to support appending like `set VCPKG_BINARY_SOURCES=%VCPKG_BINARY_SOURCES%;foo` or `export VCPKG_BINARY_SOURCES="$VCPKG_BINARY_SOURCES;foo"`

`<config>` can be any of:

- `clear` - ignore all lower priority sources (lowest priority is default, then env, then command line)

- `default[,<readwrite>]` - Reintroduce the default ~/.vcpkg/packages (as read-only or with uploading)

- `files,<path>[,<readwrite>]` - Add a file-based archive at `<path>`

- `nuget,<url>[,<readwrite>]` - Add a nuget-based source at `<url>`. This url has a similar semantic as `nuget.exe restore -source <url>` for reads and `nuget.exe push -source <url>` for writes; notably it can also be a local path.

- `nugetconfig,<path>[,<readwrite>]` - Add a nuget-based source using the NuGet.config file at `<path>`. This enables users to fully control NuGet's execution in combination with the documented NuGet environment variables. This has similar semantics to `nuget.exe push -ConfigFile <path>` and `nuget.exe restore -ConfigFile <path>`.

- `interactive` - Enables interactive mode (such as manual credential entry) for all other configured backends.

`<readwrite>` can be any of `read`, `write`, or `readwrite` to control whether packages will be consumed or published.

Backtick (`) can be used as an escape character within config strings, with double backtick (``) inserting a single backtick. All paths must be absolute.

For all backends, noninteractive operation will be the default and the vcpkg tool will take a `--interactive` parameter to enable prompting for user credentials (if needed by the backend).

To enable the 4-step flow, `vcpkg install` will take a command `--write-nuget-packages-config=<path>` which can be used in combination with `--dry-run`. This path can be relative and will resolve with respect to the current working directory.

[1]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

#### Example 4-step flow

```
PS> vcpkg install --dry-run pkg1 pkg2 pkg3 --write-nuget-packages-config=packages.config 
```

An unspecified process, such as `nuget.exe restore packages.config -packagedirectory $packages` or the [ADO task][2], restores the packages to `$packages`.

```
PS> vcpkg install pkg1 pkg2 pkg3 --binarysource=clear --binarysource=nuget,$outpkgs,upload --binarysource=nuget,$packages
```

Another unspecified process such as `nuget.exe sign $outpkgs/*.nupkg` and `nuget.exe push $outpkgs/*.nupkg` or the ADO task uploads the packages for use in future CI runs.

[2]: https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/package/nuget?view=azure-devops
