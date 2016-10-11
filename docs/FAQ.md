# Frequently Asked Questions: Vcpkg

Vcpkg is a tool to acquire C++ open source library and rebuild them on Windows. 

## Can I contribute a new library?
Yes! Start out by reading our [contribution guidelines](../CONTRIBUTING.md).

## Can Vcpkg create pre-built binary packages? What is the binary format used by Vcpkg?
In the preview release, we do not have a supported way to distribute individual binary packages. This avoids the issue of trying to use a specific pre-built package against differently built dependencies. As such, we have also not specified a stable format for the built library packages.

We instead recommend copying the entire system as a whole (which ensures that every package and its dependencies stay in sync with each other).

## How do I update libraries?
The `vcpkg update` command lists all packages which are out-of-sync with your current portfiles. To update a package, follow the instructions in the command.

## How do I get more libraries?
The list of libraries is enumerated from the [`ports\`](../ports) directory. By design, you can add and remove libraries from this directory as you see fit for yourself or your company (see [Example #2](EXAMPLES.md#example-2)).

We recommend cloning directly from [GitHub](https://github.com/microsoft/vcpkg) and using `git pull` to update the list of portfiles. Once you've updated your portfiles, `vcpkg update` will indicate any installed libraries that are now out of date.

## Can I build a private library with this tool?
Yes. Follow [Example #2](EXAMPLES.md#example-2) for creating a portfile using a fake URL. Then, either pre-seed the `downloads\` folder with a zip containing your private sources or replace the normal `vcpkg_download_distfile` and `vcpkg_extract_source_archive` with functions that unpack your source code.

## Can I use a prebuilt private library with this tool?
Yes. The `portfile.cmake` for a library is fundamentally a script that places the headers and binaries into the correct arrangement in the `${CURRENT_PACKAGES_DIR}`, so to pull in prebuilt binaries you can write a portfile which directly downloads and arranges the files.

To see an example of this, look at [`ports\opengl\portfile.cmake`](../ports/opengl/portfile.cmake) package which simply copies files out of the Windows SDK.

## Which platforms I can target with Vcpkg?
We currently target Windows Desktop (x86 and x64) as well as the Universal Windows Platform (x86, x64, and ARM). See `vcpkg help triplet` for the current list.

## Does `vcpkg.exe` run on Linux/OSX?
No, for this preview we are focusing on Windows as a host platform. If you'd be interested in having Vcpkg run on Linux or OSX, please let us know in [this issue](https://github.com/microsoft/vcpkg/issues/57).

## How do I use different versions of a library on one machine?
Within a single instance of Vcpkg (e.g. one set of `installed\`, `packages\`, `ports\` and so forth), you can only have one version of a library installed (otherwise, the headers would conflict with each other!). This is because a package in Vcpkg corresponds to the `X-dev` or `X-devel` packages in other system package managers.

To use different versions of a library (for different projects), we recommend making separate instances of Vcpkg and using the [per-project integration mechanisms](EXAMPLES.md#example-1-2-d). The versions of each library are specified by the files in `ports\`, so they are easily manipulated using standard VCS techniques. This makes it very easy to roll back the entire set of libraries to a consistent set of older versions which all work with each other. If you need to then pin a specific library forward, that is as easy as checking out the appropriate version of `ports\package\`.

If your application is very sensitive to the versions of libraries, we recommend checking in the specific set of portfiles you need into your source control along with your project sources and using the `--vcpkg-root` option to redirect the working directory of `vcpkg.exe`. 

## How does Vcpkg protect my Privacy?
See the [Privacy document](PRIVACY.md) for all information regarding privacy.

## Can I use my own CMake toolchain file with Vcpkg's toolchain file?
Yes. If you already have a CMake toolchain file, you will need to include our toolchain file at the end of yours. This should be as simple as an `include(<vcpkg_root>\scripts\buildsystems\vcpkg.cmake)` directive. Alternatively, you could copy the contents of our `scripts\buildsystems\vcpkg.cmake` into the end of your existing toolchain file.

## Can I use my own/specific flags for rebuilding libs?
Yes. In the current preview, there is not yet a standardized global way to change them, however you can edit individual portfiles and tweak the exact build process however you'd like.

By saving the changes to the portfile (and checking them in), you'll get the same results even if you're rebuilding from scratch in the future and forgot what exact settings you used.

## How is CMake used internally by Vcpkg?
Vcpkg uses CMake internally as a build scripting language. This is because CMake is already an extremely common build system for cross-platform open source libraries and is becoming very popular for C++ projects in general. It is easy to acquire on Windows (does not require system-wide installation) and reasonably legible for unfamiliar users.

## Will Vcpkg support downloading compiled binaries from a public or private server?
We do plan to eventually support downloading precompiled binaries, similar to other system package managers.

In a corporate scenario, we currently recommend building the libraries once and distributing the entire vcpkg root directory to everyone else on the project through some raw file transport such as a network share or HTTP host.

## What Visual C++ toolsets are supported?
We plan to only support Visual Studio 2015 and above.

## Can I acquire my package's sources by Git url+tag?
Yes, however we prefer compressed archives of the specific release/commit since the internal downloads and build trees are meant to be read only. Github provides archives for every commit, tag, and branch, so it's always possible to perform this substitution for repositories hosted there.

See [`ports\cpprestsdk\portfile.cmake`](../ports/cpprestsdk/portfile.cmake) for an example of using git directly.

## Why not NuGet?
NuGet is a package manager for .NET libraries with a strong dependency on MSBuild. It does not meet the specific needs of Native C++ customers in at least three ways.

- **Compilation Flavors**. With so many possible combinations of compilation options, the task of providing a truly complete set of options is intrinsicly impossible. Furthermore, the download size for reasonably complete binary packages becomes enormous. This makes it a requirement to split the results into multiple packages, but then searching becomes very difficult.

- **Binary vs Source**. Very closely tied to the first point, NuGet is designed from the ground up to provide relatively small, prebuilt binaries. Due to the nature of native code, developers need to have access to the source code to ensure ABI compatibility, performance, integrity, and debuggability.

- **Per-dll vs Per-application**. NuGet is highly project centric. This works well in managed languages with naturally stable ABIs, because base libraries can continue to evolve without breaking those higher up. However, in native languages where the ABI is much more fragile, the only robust strategy is to explicitly build each library against the exact dependencies that will be included in the final application. This is difficult to ensure in NuGet and leads to a highly disconnected and independently versioned ecosystem.

## Why not Conan?
Conan.io is a publicly-federated, project-centric, cross-platform, C++ package manager written in python. Our primary differences are:

- **Public federation vs private federation**. Conan relies on individuals publishing independent copies of each package. We believe this approach encourages a large number of packages that are all broken in different ways. We believe it is a waste of user's time to pick through the list of 20+ public packages for Boost 1.56 to determine the handful that will work for their particular situation. In contrast, we believe there should be a single, collaboratively maintained version which works for the vast majority of cases and allow users to hack freely on their private versions. We believe this will result in a set of high quality packages that are heavily tested with each other and form a fantastic base for any private modifications you need.

- **Per-dll vs Per-application**. When dependencies are independently versioned on a library level, it encourages every build environment to be a completely unique, unable to take advantage of or contribute to a solid, well tested ecosystem. In contrast, by versioning all libraries together as a platform (similar to a system package manager), we hope to congregate testing and effort on very common sets of library versions to maximize the quality and stability of the ecosystem. This also completely designs out the ability for a library to ask for versions that conflict with the application's choices (I want openssl Z and boost X but X only works with openssl Y).

- **Cross-platform vs single-platform**. While being hosted on many platforms is an excellent north star, we believe the level of system integration and stability provided by apt-get, yum, and homebrew is well worth needing to exchange `apt-get install libboost-all-dev` with `brew install boost` in automated scripts. We chose to make our system as easy as possible to integrate into a world with these very successful system managers -- one more line for `vcpkg install boost` -- instead of attempting to replace them where they are already so successful and well-loved.

- **C++/CMake vs python**. While Python is an excellent language loved by many, we believe that transparency and familiarity are the most important factors when choosing a tool as important to your workflow as a package manager. Consequently, we chose to make the implementation languages be as universally accepted as possible: C++ should be used in a C++ package manager for C++ programmers. You should not be required to learn another language just to understand your package manager.

## Why not Chocolatey?
Chocolatey is an excellent system for managing software. However, it is not currently designed to acquire redistributable developer assets and help you with debugging. Vcpkg, in comparison, is designed to get you the libraries you need to build your application and help you deliver through any platform you'd like (including Chocolatey!).
