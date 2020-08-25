## Buildsystem Integration

Vcpkg offers many ways to integrate into your build so you can do what's right for your project. There are two main categories of integration:

- [`integrate` command](#integrate)
- [`export` command](#export)

Each integration style has heuristics to deduce the correct [triplet][]. This can be overridden using [a common method](#triplet-selection) based on your buildsystem.

<a name="integrate"></a>
### Integrate Command

These link your project(s) to a specific copy of Vcpkg on your machine so any updates or new package installations will be instantly available for the next build of your project.

<a name="user-wide-msbuild"></a>
#### User-wide for MSBuild (Recommended for Open Source MSBuild projects)
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

#### CMake toolchain file (Recommended for Open Source CMake projects)
```no-highlight
cmake ../my/project -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake
```
Projects configured with the Vcpkg toolchain file will have the appropriate Vcpkg folders added to the cmake search paths. This makes all libraries available to be found through `find_package()`, `find_path()`, and `find_library()`.

See [Installing and Using Packages Example: sqlite](../examples/installing-and-using-packages.md) for a fully worked example using our CMake toolchain.

Note that we do not automatically add ourselves to your compiler include paths. To use a header-only library, simply use `find_path()`, which will correctly work on all platforms:
```cmake
# To find and use catch
find_path(CATCH_INCLUDE_DIR NAMES catch.hpp PATH_SUFFIXES catch2)
include_directories(${CATCH_INCLUDE_DIR})
```

##### Using an environment variable instead of a command line option

The `CMAKE_TOOLCHAIN_FILE` setting simply must be set before the `project()` directive is first called. This means that you can easily read from an environment variable to avoid passing it on the configure line:

```cmake
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
      CACHE STRING "")
endif()

project(myproject CXX)
```

##### Using multiple toolchain files

To use an external toolchain file with a project using vcpkg, you can set the cmake variable `VCPKG_CHAINLOAD_TOOLCHAIN_FILE` on the configure line:
```no-highlight
cmake ../my/project \
   -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake \
   -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=../my/project/compiler-settings-toolchain.cmake
```

#### Linking NuGet file

We also provide individual VS project integration through a NuGet package. This will modify the project file, so we do not recommend this approach for open source projects.
```no-highlight
PS D:\src\vcpkg> .\vcpkg integrate project
Created nupkg: D:\src\vcpkg\scripts\buildsystems\vcpkg.D.src.vcpkg.1.0.0.nupkg

With a project open, go to Tools->NuGet Package Manager->Package Manager Console and paste:
    Install-Package vcpkg.D.src.vcpkg -Source "D:/src/vcpkg/scripts/buildsystems"
```
*Note: The generated NuGet package does not contain the actual libraries. It instead acts like a shortcut (or symlink) to the vcpkg install and will "automatically" update with any changes (install/remove) to the libraries. You do not need to regenerate or update the NuGet package.*

#### Manual compiler settings

Libraries are installed into the `installed\` subfolder, partitioned by architecture (e.g. x86-windows):

* The header files are installed to `installed\x86-windows\include`
* Release `.lib` files are installed to `installed\x86-windows\lib` or `installed\x86-windows\lib\manual-link`
* Release `.dll` files are installed to `installed\x86-windows\bin`
* Debug `.lib` files are installed to `installed\x86-windows\debug\lib` or `installed\x86-windows\debug\lib\manual-link`
* Debug `.dll` files are installed to `installed\x86-windows\debug\bin`

See your build system specific documentation for how to use prebuilt binaries.

Generally, to run any produced executables you will also need to either copy the needed DLL files to the same folder as your executable or *prepend* the correct `bin\` directory to your path.

<a name="export"></a>
### Export Command
This command creates a shrinkwrapped archive containing a specific set of libraries (and their dependencies) that can be quickly and reliably shared with build servers or other users in your organization.

- `--nuget`: NuGet package (Recommended for MSBuild projects)
- `--zip`: Zip archive
- `--7zip`: 7Zip archive (Recommended for CMake projects)
- `--raw`: Raw, uncompressed folder

Each of these have the same layout, which mimics the layout of a full vcpkg:

- `installed\` contains the installed package files
- `scripts\buildsystems\vcpkg.cmake` is a toolchain file suitable for use with CMake

Additionally, NuGet packages will contain a `build\native\vcpkg.targets` that integrates with MSBuild projects.

Please also see our [blog post](https://blogs.msdn.microsoft.com/vcblog/2017/05/03/vcpkg-introducing-export-command/) for additional examples.

<a name="triplet-selection"></a>
### Triplet selection
Every integration mechanism besides manually adding the folders will deduce a [triplet][] for your project as one of:

- x86-windows
- x64-windows
- x86-uwp
- x64-uwp
- arm-uwp

#### With MSBuild
You can see the automatically deduced triplet by setting your MSBuild verbosity to Normal or higher:

> *Shortcut: Ctrl+Q "build and run"*
>
> Tools -> Options -> Projects and Solutions -> Build and Run -> MSBuild project build output verbosity

To override the automatically chosen [triplet][], you can specify the MSBuild property `VcpkgTriplet` in your `.vcxproj`. We recommend adding this to the `Globals` PropertyGroup.
```xml
<PropertyGroup Label="Globals">
  <!-- .... -->
  <VcpkgTriplet Condition="'$(Platform)'=='Win32'">x86-windows-static</VcpkgTriplet>
  <VcpkgTriplet Condition="'$(Platform)'=='x64'">x64-windows-static</VcpkgTriplet>
</PropertyGroup>
```

#### With CMake
You can set `VCPKG_TARGET_TRIPLET` on the configure line:
```no-highlight
cmake ../my/project -DVCPKG_TARGET_TRIPLET=x64-windows-static -DCMAKE_TOOLCHAIN_FILE=...
```
If you use `VCPKG_DEFAULT_TRIPLET` [environment variable](config-environment.md) to control the unqualified triplet in vcpkg command lines you can default `VCPKG_TARGET_TRIPLET` in CMake like [Using an environment variable instead of a command line option](#using-an-environment-variable-instead-of-a-command-line-option):

```cmake
if(DEFINED ENV{VCPKG_DEFAULT_TRIPLET} AND NOT DEFINED VCPKG_TARGET_TRIPLET)
  set(VCPKG_TARGET_TRIPLET "$ENV{VCPKG_DEFAULT_TRIPLET}" CACHE STRING "")
endif()
```

[triplet]: triplets.md
