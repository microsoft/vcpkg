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
consider renaming to make it clear.

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

### Avoid excessive comments in portfiles

Ideally, portfiles should be short, simple, and as declarative as possible. 
Remove any boiler plate comments introduced by the `create` command before submitting a PR.

## Build Techniques

### Do not use vendored dependencies

Do not use embedded copies of libraries. 
All dependencies should be split out and packaged separately so they can be updated and maintained.

### Prefer using CMake

When multiple buildsystems are available, prefer using CMake. 
Additionally, when appropriate, it can be easier and more maintainable to rewrite alternative buildsystems into CMake using `file(GLOB)` directives.

Examples: [abseil](../../ports/abseil/portfile.cmake)

### Choose either static or shared binaries

By default, `vcpkg_configure_cmake()` will pass in the appropriate setting for `BUILD_SHARED_LIBS`, 
however for libraries that don't respect that variable, you can switch on `VCPKG_LIBRARY_LINKAGE`:

```cmake
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KEYSTONE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -CMAKE_DISABLE_FIND_PACKAGE_ZLIB=${CMAKE_DISABLE_FIND_PACKAGE_ZLIB}
)
```

The snippet below using `vcpkg_check_features()` is equivalent,  [see the documentation](vcpkg_check_features.md).

```cmake
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  INVERTED_FEATURES
    "zlib"    CMAKE_DISABLE_FIND_PACKAGE_ZLIB
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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

## Versioning

### Follow common conventions for the `Version:` field

See our [CONTROL files document](control-files.md#version) for a full explanation of our conventions.

### Update the `Version:` field in the `CONTROL` file of any modified ports

Vcpkg uses this field to determine whether a given port is out-of-date and should be changed whenever the port's behavior changes.

Our convention for this field is to append a `-N` to the upstream version when changes need to be made.

For Example:

- Zlib's package version is currently `1.2.1`.
- You've discovered that the wrong copyright file has been deployed, and fixed that in the portfile.
- You should update the `Version:` field in the control file to `1.2.1-1`.

See our [CONTROL files document](control-files.md#version) for a full explanation of our conventions.

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

[foo](./pr-review-checklist.md#c000001)

