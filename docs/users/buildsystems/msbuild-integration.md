# MSBuild Integration (Visual Studio)

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/buildsystems/msbuild-integration.md).**

## Table of Contents

- [Integration Methods](#integration-methods)
  - [User-wide integration](#user-wide-integration)
  - [Import `.props` and `.targets`](#import-props-and-targets)
  - [Linked NuGet Package](#linked-nuget-package)
- [Common Configuration](#common-configuration)
- [Manifest Mode Configuration](#manifest-mode-configuration)

## Integration Methods

### User-wide integration

```no-highlight
vcpkg integrate install
```
This will implicitly add Include Directories, Link Directories, and Link Libraries for all packages installed with Vcpkg to all VS2015, VS2017 and VS2019 MSBuild projects. We also add a post-build action for executable projects that will analyze and copy any DLLs you need to the output folder, enabling a seamless F5 experience.

For the vast majority of libraries, this is all you need to do -- just File -> New Project and write code! However, some libraries perform conflicting behaviors such as redefining `main()`. Since you need to choose per-project which of these conflicting options you want, you will need to add those libraries to your linker inputs manually.

Here are some examples, though this is not an exhaustive list:

- Gtest provides `gtest`, `gmock`, `gtest_main`, and `gmock_main`
- SDL2 provides `SDL2main`
- SFML provides `sfml-main`
- Boost.Test provides `boost_test_exec_monitor`

To get a full list for all your installed packages, run `vcpkg owns manual-link`.

### Import `.props` and `.targets`

vcpkg can also be integrated into MSBuild projects by explicitly importing the `scripts/buildsystems/vcpkg.props` and `scripts/buildsystems/vcpkg.targets` files into each `.vcxproj`. By using relative paths, this enables vcpkg to be consumed by a submodule and automatically acquired by users when they run `git clone`.

The easiest way to add these to every project in your solution is to create `Directory.Build.props` and `Directory.Build.targets` files at the root of your repository.

The following examples assume they are at the root of your repository with a submodule of `microsoft/vcpkg` at `vcpkg`.

**Example `Directory.Build.props`**:
```xml
<Project>
 <Import Project="$(MSBuildThisFileDirectory)vcpkg\scripts\buildsystems\vcpkg.props" />
</Project>
```

**Example `Directory.Build.targets`**:
```xml
<Project>
 <Import Project="$(MSBuildThisFileDirectory)vcpkg\scripts\buildsystems\vcpkg.targets" />
</Project>
```

More information about `Directory.Build.targets` and `Directory.Build.props` can be found in the [Customize your build][1] section of the official MSBuild documentation.

[1]: https://docs.microsoft.com/visualstudio/msbuild/customize-your-build#directorybuildprops-and-directorybuildtargets

### Linked NuGet Package

**Note: This approach is not recommended for new projects, since it makes them difficult to share with others. For a portable, self-contained NuGet package, see the [`export command`](export-command.md)**

VS projects can also be integrated through a NuGet package. This will modify the project file, so we do not recommend this approach for open source projects.

```no-highlight
PS D:\src\vcpkg> .\vcpkg integrate project
Created nupkg: D:\src\vcpkg\scripts\buildsystems\vcpkg.D.src.vcpkg.1.0.0.nupkg

With a project open, go to Tools->NuGet Package Manager->Package Manager Console and paste:
    Install-Package vcpkg.D.src.vcpkg -Source "D:/src/vcpkg/scripts/buildsystems"
```

*Note: The generated NuGet package does not contain the actual libraries. It instead acts like a shortcut (or symlink) to the vcpkg install and will "automatically" update with any changes (install/remove) to the libraries. You do not need to regenerate or update the NuGet package.*

## Common Configuration

### `VcpkgEnabled` (Use Vcpkg)

This can be set to "false" to explicitly disable vcpkg integration for the project

### `VcpkgConfiguration` (Vcpkg Configuration)

If your configuration names are too complex for vcpkg to guess correctly, you can assign this property to `Release` or `Debug` to explicitly tell vcpkg what variant of libraries you want to consume.

### `VcpkgEnableManifest` (Use Vcpkg Manifest)

This property must be set to `true` in order to consume from a local `vcpkg.json` file. If set to `false`, any local `vcpkg.json` files will be ignored.

This currently defaults to `false`, but will default to `true` in the future.

### `VcpkgTriplet` (Triplet)

This property controls the triplet to consume libraries from, such as `x64-windows-static` or `arm64-windows`.

If this is not explicitly set, vcpkg will deduce the correct triplet based on your Visual Studio settings. vcpkg will only deduce triplets that use dynamic library linkage and dynamic CRT linkage; if you want static dependencies or to use the static CRT (`/MT`), you will need to set the triplet manually.

You can see the automatically deduced triplet by setting your MSBuild verbosity to Normal or higher:

> *Shortcut: Ctrl+Q "build and run"*
>
> Tools -> Options -> Projects and Solutions -> Build and Run -> MSBuild project build output verbosity

See also [Triplets](../triplets.md)

### `VcpkgHostTriplet` (Host Triplet)

This can be set to a custom triplet to use for resolving host dependencies.

If unset, this will default to the "native" triplet (x64-windows).

See also [Host Dependencies](../host-dependencies.md).

### `VcpkgInstalledDir` (Installed Directory)

This property defines the location vcpkg will install and consume libraries from.

In manifest mode, this defaults to `$(VcpkgManifestRoot)\vcpkg_installed\$(VcpkgTriplet)\`. In classic mode, this defaults to `$(VcpkgRoot)\installed\`.

## Manifest Mode Configuration

To use manifests (`vcpkg.json`) with MSBuild, first you need to use one of the integration methods above. Then, add a vcpkg.json above your project file (such as in the root of your source repository) and set the property `VcpkgEnableManifest` to `true`. You can set this property via the IDE in `Project Properties -> Vcpkg -> Use Vcpkg Manifest` (note: you may need to reload the IDE to see the vcpkg Property Page).

vcpkg will automatically run during your project's build and install any listed dependencies to `vcpkg_installed/$(VcpkgTriplet)/` adjacent to the `vcpkg.json` file; these libraries will then automatically be included in and linked to your MSBuild projects.

**Known issues**

* Visual Studio 2015 does not correctly track edits to the `vcpkg.json` and `vcpkg-configuration.json` files, and will not respond to changes unless a `.cpp` is edited.

<a id="vcpkg-additional-install-options"></a>

### `VcpkgAdditionalInstallOptions` (Additional Options)

When using a manifest, this option specifies additional command line flags to pass to the underlying vcpkg tool invocation. This can be used to access features that have not yet been exposed through another option.

### `VcpkgManifestInstall` (Install Vcpkg Dependencies)

This property can be set to `false` to disable automatic dependency restoration during project build. Dependencies must be manually restored via the vcpkg command line separately.
