# Maintainer Guidelines and Policies

This document lists a set of policies that you should apply when adding or updating a port recipe.
It is intended to serve the role of
[Debian's Policy Manual](https://www.debian.org/doc/debian-policy/),
[Homebrew's Maintainer Guidelines](https://docs.brew.sh/Maintainer-Guidelines), and
[Homebrew's Formula Cookbook](https://docs.brew.sh/Formula-Cookbook).

## PR Structure

### Make separate Pull Requests per port

Whenever possible, separate changes into multiple PRs.
This makes them significantly easier to review and prevents issues with one set of changes from holding up every other change.

### Avoid trivial changes in untouched files

For example, avoid reformatting or renaming variables in portfiles that otherwise have no reason to be modified for the issue at hand.
However, if you need to modify the file for the primary purpose of the PR (updating the library),
then obviously beneficial changes like fixing typos are appreciated!

### Check names against other repositories

A good service to check many at once is [Repology](https://repology.org/).
If the library you are adding could be confused with another one,
consider renaming to make it clear. We prefer when names are longer and/or
unlikely to conflict with any future use of the same name. If the port refers
to a library on GitHub, a good practice is to prefix the name with the organization
if there is any chance of confusion.

### Use GitHub Draft PRs

GitHub Draft PRs are a great way to get CI or human feedback on work that isn't yet ready to merge.
Most new PRs should be opened as drafts and converted to normal PRs once the CI passes.

More information about GitHub Draft PRs:
https://github.blog/2019-02-14-introducing-draft-pull-requests/

## Portfiles

### Avoid deprecated helper functions

At this time, the following helpers are deprecated:

1. `vcpkg_extract_source_archive()` should be replaced by [`vcpkg_extract_source_archive_ex()`](vcpkg_extract_source_archive_ex.md)
2. `vcpkg_apply_patches()` should be replaced by the `PATCHES` arguments to the "extract" helpers (e.g. [`vcpkg_from_github()`](vcpkg_from_github.md))
3. `vcpkg_build_msbuild()` should be replaced by [`vcpkg_install_msbuild()`](vcpkg_install_msbuild.md)
4. `vcpkg_copy_tool_dependencies()` should be replaced by [`vcpkg_copy_tools()`](vcpkg_copy_tools.md)
5. `vcpkg_configure_cmake` should be replaced by [`vcpkg_cmake_configure()`](ports/vcpkg-cmake/vcpkg_cmake_configure.md#vcpkg_cmake_configure) after removing `PREFER_NINJA` (from port [`vcpkg-cmake`](ports/vcpkg-cmake.md#vcpkg-cmake))
6. `vcpkg_build_cmake` should be replaced by [`vcpkg_cmake_build()`](ports/vcpkg-cmake/vcpkg_cmake_build.md#vcpkg_cmake_build) (from port [`vcpkg-cmake`](ports/vcpkg-cmake.md#vcpkg-cmake))
7. `vcpkg_install_cmake` should be replaced by [`vcpkg_cmake_install()`](ports/vcpkg-cmake/vcpkg_cmake_install.md#vcpkg_cmake_install) (from port [`vcpkg-cmake`](ports/vcpkg-cmake.md#vcpkg-cmake))
8. `vcpkg_fixup_cmake_targets` should be replaced by [`vcpkg_cmake_config_fixup`](ports/vcpkg-cmake-config/vcpkg_cmake_config_fixup.md#vcpkg_cmake_config_fixup) (from port [`vcpkg-cmake-config`](ports/vcpkg-cmake-config.md#vcpkg-cmake-config))

Some of the replacement helper functions are in "tools ports" to allow consumers to pin their
behavior at specific versions, to allow locking the behavior of the helpers at a particular
version. Tools ports need to be added to your port's `"dependencies"`, like so:

```json
{
  "name": "vcpkg-cmake",
  "host": true
},
{
  "name": "vcpkg-cmake-config",
  "host": true
}
```

### Avoid excessive comments in portfiles

Ideally, portfiles should be short, simple, and as declarative as possible.
Remove any boiler plate comments introduced by the `create` command before submitting a PR.

### Ports must not be path dependent

Ports must not change their behavior based on which ports are already installed in a form that would change which contents that port installs. For example, given:

```
> vcpkg install a
> vcpkg install b
> vcpkg remove a
```

and

```
> vcpkg install b
```

the files installed by `b` must be the same, regardless of influence by the previous installation of `a`. This means that ports must not try to detect whether something is provided in the installed tree by another port before taking some action. A specific and common cause of such "path dependent" behavior is described below in "When defining features, explicitly control dependencies."

### Unique port attribution rule

In the entire vcpkg system, no two ports a user is expected to use concurrently may provide the same file. If a port tries to install a file already provided by another file, installation will fail. If a port wants to use an extremely common name for a header, for example, it should place those headers in a subdirectory rather than in `include`.

### Add CMake exports in an unofficial- namespace

A core design ideal of vcpkg is to not create "lock-in" for customers. In the build system, there should be no difference between depending on a library from the system, and depending on a library from vcpkg. To that end, we avoid adding CMake exports or targets to existing libraries with "the obvious name", to allow upstreams to add their own official CMake exports without conflicting with vcpkg.

To that end, any CMake configs that the port exports, which are not in the upstream library, should have `unofficial-` as a prefix. Any additional targets should be in the `unofficial::<port>::` namespace.

This means that the user should see:
 * `find_package(unofficial-<port> CONFIG)` as the way to get at the unique-to-vcpkg package
 * `unofficial::<port>::<target>` as an exported target from that port.

Examples:
 * [`brotli`](https://github.com/microsoft/vcpkg/blob/4f0a640e4c5b74166b759a862d7527c930eff32e/ports/brotli/install.patch) creates the `unofficial-brotli` package, producing target `unofficial::brotli::brotli`.

## Features

### Do not use features to implement alternatives

Features must be treated as additive functionality. If port[featureA] installs and port[featureB] installs, then port[featureA,featureB] must install. Moreover, if a second port depends on [featureA] and a third port depends on [featureB], installing both the second and third ports should have their dependencies satisfied.

Libraries in this situation must choose one of the available options as expressed in vcpkg, and users who want a different setting must use overlay ports at this time.

Existing examples we would not accept today retained for backwards compatibility:
  * `libgit2`, `libzip`, `open62541` all have features for selecting a TLS or crypto backend. Note that `curl` has different crypto backend options but allows selecting between them at runtime, meaning the above tenet is maintained.
  * `darknet` has `opencv2`, `opencv3`, features to control which version of opencv to use for its dependencies.

### A feature may engage preview or beta functionality

Notwithstanding the above, if there is a preview branch or similar where the preview functionality has a high probability of not disrupting the non-preview functionality (for example, no API removals), a feature is acceptable to model this setting.

Examples:
  * The Azure SDKs (of the form `azure-Xxx`) have a `public-preview` feature.
  * `imgui` has an `experimental-docking` feature which engages their preview docking branch which uses a merge commit attached to each of their public numbered releases.

### Default features should enable behaviors, not APIs

If a consumer is depending directly upon a library, they can list out any desired features easily (`library[feature1,feature2]`). However, if a consumer _does not know_ they are using a library, they cannot list out those features. If that hidden library is like `libarchive` where features are adding additional compression algorithms (and thus behaviors) to an existing generic interface, default features offer a way to ensure a reasonably functional transitive library is built even if the final consumer doesn't name it directly.

If the feature adds additional APIs (or executables, or library binaries) and doesn't modify the behavior of existing APIs, it should be left off by default. This is because any consumer which might want to use those APIs can easily require it via their direct reference.

If in doubt, do not mark a feature as default.

### Do not use features to control alternatives in published interfaces

If a consumer of a port depends on only the core functionality of that port, with high probability they must not be broken by turning on the feature. This is even more important when the alternative is not directly controlled by the consumer, but by compiler settings like `/std:c++17` / `-std=c++17`.

Existing examples we would not accept today retained for backwards compatibility:
  * `redis-plus-plus[cxx17]` controls a polyfill but does not bake the setting into the installed tree.
  * `ace[wchar]` changes all APIs to accept `const wchar_t*` rather than `const char*`.

### A feature may replace polyfills with aliases provided that replacement is baked into the installed tree

Notwithstanding the above, ports may remove polyfills with a feature, as long as:
  1. Turning on the feature changes the polyfills to aliases of the polyfilled entity
  2. The state of the polyfill is baked into the installed headers, such that ABI mismatch "impossible" runtime errors are unlikely
  3. It is possible for a consumer of the port to write code which works in both modes, for example by using a typedef which is either polyfilled or not

Example:
  * `abseil[cxx17]` changes `absl::string_view` to a replacement or `std::string_view`; the patch
https://github.com/microsoft/vcpkg/blob/981e65ce0ac1f6c86e5a5ded7824db8780173c76/ports/abseil/fix-cxx-standard.patch implements the baking requirement

### Recommended solutions

If it's critical to expose the underlying alternatives, we recommend providing messages at build time to instruct the user on how to copy the port into a private overlay:
```cmake
set(USING_DOG 0)
message(STATUS "This version of LibContosoFrobnicate uses the Kittens backend. To use the Dog backend instead, create an overlay port of this with USING_DOG set to 1 and the `kittens` dependency replaced with `dog`.")
message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
message(STATUS "See the overlay ports documentation at https://github.com/microsoft/vcpkg/blob/master/docs/specifications/ports-overlay.md")
```

## Build Techniques

### Do not use vendored dependencies

Do not use embedded copies of libraries.
All dependencies should be split out and packaged separately so they can be updated and maintained.

### Prefer using CMake

When multiple buildsystems are available, prefer using CMake.
Additionally, when appropriate, it can be easier and more maintainable to rewrite alternative buildsystems into CMake using `file(GLOB)` directives.

Examples: [abseil](../../ports/abseil/portfile.cmake)

### Choose either static or shared binaries

By default, `vcpkg_cmake_configure()` will pass in the appropriate setting for `BUILD_SHARED_LIBS`,
however for libraries that don't respect that variable, you can switch on `VCPKG_LIBRARY_LINKAGE`:

```cmake
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KEYSTONE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DKEYSTONE_BUILD_STATIC=${KEYSTONE_BUILD_STATIC}
        -DKEYSTONE_BUILD_SHARED=${KEYSTONE_BUILD_SHARED}
)
```

### When defining features, explicitly control dependencies

When defining a feature that captures an optional dependency,
ensure that the dependency will not be used accidentally when the feature is not explicitly enabled.

```cmake
if ("zlib" IN_LIST FEATURES)
  set(CMAKE_DISABLE_FIND_PACKAGE_ZLIB OFF)
else()
  set(CMAKE_DISABLE_FIND_PACKAGE_ZLIB ON)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DCMAKE_DISABLE_FIND_PACKAGE_ZLIB=${CMAKE_DISABLE_FIND_PACKAGE_ZLIB}
)
```

The snippet below using `vcpkg_check_features()` is equivalent,  [see the documentation](vcpkg_check_features.md).

```cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    "zlib"    CMAKE_DISABLE_FIND_PACKAGE_ZLIB
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      ${FEATURE_OPTIONS}
)
```

Note that `ZLIB` in the above is case-sensitive. See the [cmake documentation](https://cmake.org/cmake/help/v3.15/variable/CMAKE_DISABLE_FIND_PACKAGE_PackageName.html) for more details.

### Place conflicting libs in a `manual-link` directory

A lib is considered conflicting if it does any of the following:
+ Define `main`
+ Define malloc
+ Define symbols that are also declared in other libraries

Conflicting libs are typically by design and not considered a defect.  Because some build systems link against everything in the lib directory, these should be moved into a subdirectory named `manual-link`.

## Manifests and CONTROL files

When adding a new port, use the new manifest syntax for defining a port;
you may also change over to manifests when modifying an existing port.
You may do so easily by running the `vcpkg format-manifest` command, which will convert existing CONTROL
files into manifest files. Do not convert CONTROL files that have not been modified.

## Versioning

### Follow common conventions for the `"version"` field

See our [versioning documentation](../users/versioning.md#version-schemes) for a full explanation of our conventions.

### Update the `"port-version"` field in the manifest file of any modified ports

Vcpkg uses this field to determine whether a given port is out-of-date and should be changed whenever the port's behavior changes.

Our convention is to use the `"port-version"` field for changes to the port that don't change the upstream version, and to reset the `"port-version"` back to zero when an update to the upstream version is made.

For Example:

- Zlib's package version is currently `1.2.1`, with no explicit `"port-version"` (equivalent to a `"port-version"` of `0`).
- You've discovered that the wrong copyright file has been deployed, and fixed that in the portfile.
- You should update the `"port-version"` field in the manifest file to `1`.

See our [manifest files document](manifest-files.md#port-version) for a full explanation of our conventions.

### Update the version files in `versions/` of any modified ports

Vcpkg uses a set of metadata files to power its versioning feature.
These files are located in the following locations:
* `${VCPKG_ROOT}/versions/baseline.json`, (this file is common to all ports) and
* `${VCPKG_ROOT}/versions/${first-letter-of-portname}-/${portname}.json` (one per port).

For example, for `zlib` the relevant files are:
* `${VCPKG_ROOT}/versions/baseline.json`
* `${VCPKG_ROOT}/versions/z-/zlib.json`

We expect that each time you update a port, you also update its version files.

**The recommended method to update these files is to run the `x-add-version` command, e.g.:**

```
vcpkg x-add-version zlib
```

If you're updating multiple ports at the same time, instead you can run:

```
vcpkg x-add-version --all
```

To update the files for all modified ports at once.

_NOTE: These commands require you to have committed your changes to the ports before running them. The reason is that the Git SHA of the port directory is required in these version files. But don't worry, the `x-add-version` command will warn you if you have local changes that haven't been committed._

See our [versioning specification](../specifications/versioning.md) and [registries specification](../specifications/registries-2.md) to learn how vcpkg interacts with these files.

## Patching

### Prefer options over patching

It is preferable to set options in a call to `vcpkg_configure_xyz()` over patching the settings directly.

Common options that allow avoiding patching:
1. [MSBUILD] `<PropertyGroup>` settings inside the project file can be overridden via `/p:` parameters
2. [CMAKE] Calls to `find_package(XYz)` in CMake scripts can be disabled via [`-DCMAKE_DISABLE_FIND_PACKAGE_XYz=ON`](https://cmake.org/cmake/help/v3.15/variable/CMAKE_DISABLE_FIND_PACKAGE_PackageName.html)
3. [CMAKE] Cache variables (declared as `set(VAR "value" CACHE STRING "Documentation")` or `option(VAR "Documentation" "Default Value")`) can be overridden by just passing them in on the command line as `-DVAR:STRING=Foo`. One notable exception is if the `FORCE` parameter is passed to `set()`. See also the [CMake `set` documentation](https://cmake.org/cmake/help/v3.15/command/set.html)

### Prefer patching over overriding `VCPKG_<VARIABLE>` values

Some variables prefixed with `VCPKG_<VARIABLE>` have an equivalent `CMAKE_<VARIABLE>`.
However, not all of them are passed to the internal package build [(see implementation: Windows toolchain)](../../scripts/toolchains/windows.cmake).

Consider the following example:

```cmake
set(VCPKG_C_FLAGS "-O2 ${VCPKG_C_FLAGS}")
set(VCPKG_CXX_FLAGS "-O2 ${VCPKG_CXX_FLAGS}")
```

Using `vcpkg`'s built-in toolchains this works, because the value of `VCPKG_<LANG>_FLAGS` is forwarded to the appropriate `CMAKE_LANG_FLAGS` variable. But, a custom toolchain that is not aware of `vcpkg`'s variables will not forward them.

Because of this, it is preferable to patch the buildsystem directly when setting `CMAKE_<LANG>_FLAGS`.

### Minimize patches

When making changes to a library, strive to minimize the final diff. This means you should _not_ reformat the upstream source code when making changes that affect a region. Also, when disabling a conditional, it is better to add a `AND FALSE` or `&& 0` to the condition than to delete every line of the conditional.

This helps to keep the size of the vcpkg repository down as well as improves the likelihood that the patch will apply to future code versions.

### Do not implement features in patches

The purpose of patching in vcpkg is to enable compatibility with compilers, libraries, and platforms. It is not to implement new features in lieu of following proper Open Source procedure (submitting an Issue/PR/etc).

## Do not build tests/docs/examples by default

When submitting a new port, check for any options like `BUILD_TESTS` or `WITH_TESTS` or `POCO_ENABLE_SAMPLES` and ensure the additional binaries are disabled. This minimizes build times and dependencies for the average user.

Optionally, you can add a `test` feature which enables building the tests, however this should not be in the `Default-Features` list.

## Enable existing users of the library to switch to vcpkg

### Do not add `CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS`

Unless the author of the library is already using it, we should not use this CMake functionality because it interacts poorly with C++ templates and breaks certain compiler features. Libraries that don't provide a .def file and do not use __declspec() declarations simply do not support shared builds for Windows and should be marked as such with `vcpkg_check_linkage(ONLY_STATIC_LIBRARY)`.

### Do not rename binaries outside the names given by upstream

This means that if the upstream library has different names in release and debug (libx versus libxd), then the debug library should not be renamed to `libx`. Vice versa, if the upstream library has the same name in release and debug, we should not introduce a new name.

Important caveat:
- Static and shared variants often should be renamed to a common scheme. This enables consumers to use a common name and be ignorant of the downstream linkage. This is safe because we only make one at a time available.

Note that if a library generates CMake integration files (`foo-config.cmake`), renaming must be done through patching the CMake build itself instead of simply calling `file(RENAME)` on the output archives/LIBs.

Finally, DLL files on Windows should never be renamed post-build because it breaks the generated LIBs.

## Code format

### Vcpkg internal code

We require the C++ code inside vcpkg to follow the clang-format, if you change them. Please perform the following steps after modification:

- Use Visual Studio:
1. Configure your [clang-format tools](https://devblogs.microsoft.com/cppblog/clangformat-support-in-visual-studio-2017-15-7-preview-1/).
2. Open the modified file.
3. Use shortcut keys Ctrl+K, Ctrl+D to format the current file.

- Use tools:
1. Install [llvm clang-format](https://releases.llvm.org/download.html#10.0.0)
2. Run command:
```cmd
> LLVM_PATH/bin/clang-format.exe -style=file -i changed_file.cpp
```

### Manifests

We require that the manifest file be formatted. Use the following command to format all manifest files:

```cmd
> vcpkg format-manifest --all
```

## Useful implementation notes

### Portfiles are run in Script Mode

While `portfile.cmake`'s and `CMakeLists.txt`'s share a common syntax and core CMake language constructs, portfiles run in "Script Mode", whereas `CMakeLists.txt` files run in "Build Mode" (unofficial term). The most important difference between these two modes is that "Script Mode" does not have a concept of "Target" -- any behaviors that depend on the "target" machine (`CMAKE_CXX_COMPILER`, `CMAKE_EXECUTABLE_SUFFIX`, `CMAKE_SYSTEM_NAME`, etc) will not be correct.

Portfiles have direct access to variables set in the triplet file, but `CMakeLists.txt`s do not (though there is often a translation that happens -- `VCPKG_LIBRARY_LINKAGE` versus `BUILD_SHARED_LIBS`).

Portfiles and CMake builds invoked by portfiles are run in different processes. Conceptually:

```no-highlight
+----------------------------+       +------------------------------------+
| CMake.exe                  |       | CMake.exe                          |
+----------------------------+       +------------------------------------+
| Triplet file               | ====> | Toolchain file                     |
| (x64-windows.cmake)        |       | (scripts/buildsystems/vcpkg.cmake) |
+----------------------------+       +------------------------------------+
| Portfile                   | ====> | CMakeLists.txt                     |
| (ports/foo/portfile.cmake) |       | (buildtrees/../CMakeLists.txt)     |
+----------------------------+       +------------------------------------+
```

To determine the host in a portfile, the standard CMake variables are fine (`CMAKE_HOST_WIN32`).

To determine the target in a portfile, the vcpkg triplet variables should be used (`VCPKG_CMAKE_SYSTEM_NAME`).

See also our [triplet documentation](../users/triplets.md) for a full enumeration of possible settings.
