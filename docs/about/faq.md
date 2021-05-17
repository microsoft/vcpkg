# Frequently Asked Questions

## Can I contribute a new library?
Yes! Start out by reading our [contribution guidelines](https://github.com/Microsoft/vcpkg/blob/master/CONTRIBUTING.md).
If you want to contribute but don't have a particular library in mind then take a look at the list
of [new port requests](https://github.com/Microsoft/vcpkg/issues?q=is%3Aissue+is%3Aopen+label%3Acategory%3Anew-port).

## Can Vcpkg create pre-built binary packages? What is the binary format used by Vcpkg?
Yes! See [the `export` command](../users/integration.md#export-command).

## How do I update libraries?
The `vcpkg update` command lists all packages which are out-of-sync with your current portfiles. To update a package, follow the instructions in the command.

## How do I get more libraries?
The list of libraries is enumerated from the [`ports\`](https://github.com/Microsoft/vcpkg/blob/master/ports) directory. By design, you can add and remove libraries from this directory as you see fit for yourself or your company -- see our examples on packaging [zipfiles](../examples/packaging-zipfiles.md) and [GitHub repos](../examples/packaging-github-repos.md).

We recommend cloning directly from [GitHub](https://github.com/microsoft/vcpkg) and using `git pull` to update the list of portfiles. Once you've updated your portfiles, `vcpkg update` will indicate any installed libraries that are now out of date.

## Can I build a private library with this tool?
Yes. Follow [our packaging zlib Example](../examples/packaging-zipfiles.md) for creating a portfile using a fake URL. Then, either pre-seed the `downloads\` folder with a zip containing your private sources or replace the normal calls to `vcpkg_download_distfile` and `vcpkg_extract_source_archive` with functions that unpack your source code.

## Can I use a prebuilt private library with this tool?
Yes. The `portfile.cmake` for a library is fundamentally a script that places the headers and binaries into the correct arrangement in the `${CURRENT_PACKAGES_DIR}`, so to pull in prebuilt binaries you can write a portfile which directly downloads and arranges the files.

To see an example of this, look at [`ports\opengl\portfile.cmake`](https://github.com/microsoft/vcpkg/blob/master/ports/opengl/portfile.cmake) which simply copies files out of the Windows SDK.

## Which platforms I can target with Vcpkg?
We currently target Windows Desktop (x86 and x64) as well as the Universal Windows Platform (x86, x64, and ARM). See `vcpkg help triplet` for the current list.

## Does Vcpkg run on Linux/OSX?
Yes! We continuously test on OSX and Ubuntu 16.04, however we know users have been successful with Arch, Fedora, and FreeBSD. If you have trouble with your favorite Linux distribution, let us know in an issue and we'd be happy to help!

## How do I update vcpkg?
Execute `git pull` to get the latest sources, then run `bootstrap-vcpkg.bat` (Windows) or `./bootstrap-vcpkg.sh` (Unix) to update vcpkg.

## How do I use different versions of a library on one machine?
Within a single instance of Vcpkg (e.g. one set of `installed\`, `packages\`, `ports\` and so forth), you can only have one version of a library installed (otherwise, the headers would conflict with each other!). For those with experience with system-wide package managers, packages in Vcpkg correspond to the `X-dev` or `X-devel` packages.

To use different versions of a library for different projects, we recommend making separate instances of Vcpkg and using the [per-project integration mechanisms](../users/integration.md). The versions of each library are specified by the files in `ports\`, so they are easily manipulated using standard `git` commands. This makes it very easy to roll back the entire set of libraries to a consistent set of older versions which all work with each other. If you need to then pin a specific library forward, that is as easy as checking out the appropriate version of `ports\<package>\`.

If your application is very sensitive to the versions of libraries, we recommend checking in the specific set of portfiles you need into your source control along with your project sources and using the `--vcpkg-root` option to redirect the working directory of `vcpkg.exe`.

## How does Vcpkg protect my privacy?
See the [Privacy document](privacy.md) for all information regarding privacy.

## Can I use my own CMake toolchain file with Vcpkg's toolchain file?
Yes. If you already have a CMake toolchain file, you will need to include our toolchain file at the end of yours. This should be as simple as an `include(<vcpkg_root>\scripts\buildsystems\vcpkg.cmake)` directive. Alternatively, you could copy the contents of our `scripts\buildsystems\vcpkg.cmake` into the end of your existing toolchain file.

## Can I use my own/specific flags for rebuilding libs?
Yes. In the current version, there is not yet a standardized global way to change them, however you can edit individual portfiles and tweak the exact build process however you'd like.

By saving the changes to the portfile (and checking them in), you'll get the same results even if you're rebuilding from scratch in the future and forgot what exact settings you used.

## Can I get Vcpkg integration for custom configurations?

Yes. While Vcpkg will only produce the standard "Release" and "Debug" configurations when building a library, you can get integration support for your projects' custom configurations, in addition to your project's standard configurations.

First of all, Vcpkg will automatically assume any custom configuration starting with "Release" (resp. "Debug") as a configuration that is compatible with the standard "Release" (resp. "Debug") configuration and will act accordingly.

For other configurations, you only need to override the MSBuild `$(VcpkgConfiguration)` macro in your project file (.vcxproj) to declare the compatibility between your configuration, and the target standard configuration. Unfortunately, due to the sequential nature of MSBuild, you'll need to add those settings much higher in your vcxproj so that it is declared before the Vcpk integration is loaded. It is recommend that the `$(VcpkgConfiguration)` macro is added to the "Globals" PropertyGroup.

For example, you can add support for your "MyRelease" configuration by adding in your project file:
```
<PropertyGroup Label="Globals">
  ...
  <VcpkgConfiguration Condition="'$(Configuration)' == 'MyRelease'">Release</VcpkgConfiguration>
</PropertyGroup>
```
Of course, this will only produce viable binaries if your custom configuration is compatible with the target configuration (e.g. they should both link with the same runtime library).

## I can't use user-wide integration. Can I use a per-project integration?

Yes. A NuGet package suitable for per-project use can be generated via either the `vcpkg integrate project` command (lightweight linking) or the `vcpkg export --nuget` command (shrinkwrapped).

A lower level mechanism to achieve the same as the `vcpkg integrate project` NuGet package is via the `<vcpkg_root>\scripts\buildsystems\msbuild\vcpkg.targets` file. All you need is to import it in your .vcxproj file, replacing `<vcpkg_root>` with the path where you installed vcpkg:

```
<Import Project="<vcpkg_root>\scripts\buildsystems\msbuild\vcpkg.targets" />
```

## How can I remove temporary files?

You can save some disk space by completely removing the `packages\`, `buildtrees\`, and `downloads\` folders.

## How is CMake used internally by Vcpkg?
Vcpkg uses CMake internally as a build scripting language. This is because CMake is already an extremely common build system for cross-platform open source libraries and is becoming very popular for C++ projects in general. It is easy to acquire on Windows, does not require system-wide installation, and legible for unfamiliar users.

## Will Vcpkg support downloading compiled binaries from a public or private server?
We would like to eventually support downloading precompiled binaries, similar to other system package managers.

In a corporate scenario, we currently recommend building the libraries once and distributing the entire vcpkg root directory to everyone else on the project through some raw file transport such as a network share or HTTP host. See the [`export`](../users/integration.md#export) command.

## What Visual C++ toolsets are supported?
We support Visual Studio 2015 Update 3 and above.

## Why does Visual Studio not use my libraries with user-wide integration enabled?
Enabling user-wide integration (`vcpkg integrate install`) changes the default for some project properties. In particular, "C/C++/General/Additional Include Directories" and "Linker/General/Additional Library Directories" are normally blank *without* user-wide integration. *With* integration, a blank value means that the augmented default supplied by vcpkg is overridden, and headers/libraries will not be found. To reinstate the default, set the properties to inherit from parent.

## Why not NuGet?
NuGet is a package manager for .NET libraries with a strong dependency on MSBuild. It does not meet the specific needs of Native C++ customers in at least three ways.

- **Compilation Flavors**. With so many possible combinations of compilation options, the task of providing a truly complete set of options is intrinsically impossible. Furthermore, the download size for reasonably complete binary packages becomes enormous. This makes it a requirement to split the results into multiple packages, but then searching becomes very difficult.

- **Binary vs Source**. Very closely tied to the first point, NuGet is designed from the ground up to provide relatively small, prebuilt binaries. Due to the nature of native code, developers need to have access to the source code to ensure ABI compatibility, performance, integrity, and debuggability.

- **Per-dll vs Per-application**. NuGet is highly project centric. This works well in managed languages with naturally stable ABIs, because base libraries can continue to evolve without breaking those higher up. However, in native languages where the ABI is much more fragile, the only robust strategy is to explicitly build each library against the exact dependencies that will be included in the final application. This is difficult to ensure in NuGet and leads to a highly disconnected and independently versioned ecosystem.

## Why not Conan?
Conan.io is a publicly-federated, project-centric, cross-platform, C++ package manager written in python. Our primary differences are:

- **Public federation vs private federation**. Conan relies on individuals publishing independent copies of each package. We believe this approach encourages a large number of packages that are all broken in different ways. We believe it is a waste of user's time to pick through the list of 20+ public packages for Boost 1.56 to determine the handful that will work for their particular situation. In contrast, we believe there should be a single, collaboratively maintained version which works for the vast majority of cases and allow users to hack freely on their private versions. We believe this will result in a set of high quality packages that are heavily tested with each other and form a fantastic base for any private modifications you need.

- **Per-dll vs Per-application**. When dependencies are independently versioned on a library level, it encourages every build environment to be a completely unique, unable to take advantage of or contribute to a solid, well tested ecosystem. In contrast, by versioning all libraries together as a platform (similar to a system package manager), we hope to congregate testing and effort on very common sets of library versions to maximize the quality and stability of the ecosystem. This also completely designs out the ability for a library to ask for versions that conflict with the application's choices (I want openssl Z and boost X but X only claims to work with openssl Y).

- **Cross-platform vs single-platform**. While being hosted on many platforms is an excellent north star, we believe the level of system integration and stability provided by apt-get, yum, and homebrew is well worth needing to exchange `apt-get install libboost-all-dev` with `brew install boost` in automated scripts. We chose to make our system as easy as possible to integrate into a world with these very successful system managers -- one more line for `vcpkg install boost` -- instead of attempting to replace them where they are already so successful and well-loved.

- **C++/CMake vs python**. While Python is an excellent language loved by many, we believe that transparency and familiarity are the most important factors when choosing a tool as important to your workflow as a package manager. Consequently, we chose to make the implementation languages be as universally accepted as possible: C++ should be used in a C++ package manager for C++ programmers. You should not be required to learn another programming language just to understand your package manager.

## Why not Chocolatey?
Chocolatey is an excellent system for managing applications. However, it is not currently designed to acquire redistributable developer assets and help you with debugging. Vcpkg, in comparison, is designed to get you the libraries you need to build your application and help you deliver through any platform you'd like (including Chocolatey!).
