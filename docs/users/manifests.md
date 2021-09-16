# Manifest Mode

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/manifests.md).**

vcpkg has two modes of consuming dependencies - classic mode and manifest mode.

In classic mode, vcpkg produces an "installed" tree, whose contents are changed by explicit calls to `vcpkg install` or
`vcpkg remove`. The installed tree is intended for consumption by any number of projects: for example, installing a
bunch of libraries and then using those libraries from Visual Studio, without additional configuration. Because the
installed tree is not associated with an individual project, it's similar to tools like `brew` or `apt`, except that the
installed tree is vcpkg-installation-local, rather than global to a system or user.

In manifest mode, an installed tree is associated with a particular project rather than the vcpkg installation. The set
of installed ports is controlled by editing the project's "manifest file", and the installed tree is placed in the
project directory or build directory. This mode acts more similarly to language package managers like Cargo, or npm. We
recommend using this manifest mode whenever possible, because it allows one to encode a project's dependencies
explicitly in a project file, rather than in the documentation, making your project much easier to consume.

Manifest mode is in beta, but it can be used from the CMake or MSBuild integration, which will be stable when used via
things like `find_package`. This is the recommended way to use manifest mode.

Check out the [manifest cmake example](../examples/manifest-mode-cmake.md) for an example project using CMake and
manifest mode.

## Table of Contents

- [Simple Example Manifest](#simple-example-manifest)
- [Manifest Syntax Reference](#manifest-syntax-reference)
- [Command Line Interface](#command-line-interface)
- [CMake Integration](#cmake-integration)
- [MSBuild Integration](#msbuild-integration)

See also [the original specification](../specifications/manifests.md) for more low-level details.

## Simple Example Manifest

```json
{
  "$schema": "https://raw.githubusercontent.com/microsoft/vcpkg/master/scripts/vcpkg.schema.json",
  "name": "my-application",
  "version": "0.15.2",
  "dependencies": [
    "boost-system",
    {
      "name": "cpprestsdk",
      "default-features": false
    },
    "libxml2",
    "yajl"
  ]
}
```

## Manifest Syntax Reference

A manifest is a JSON-formatted file named `vcpkg.json` which lies at the root of your project.
It contains all the information a person needs to know to get dependencies for your project,
as well as all the metadata about your project that a person who depends on you might be interested in.

Manifests follow strict JSON: they can't contain C++-style comments (`//`) nor trailing commas. However
you can use field names that start with `$` to write your comments in any object that has a well-defined set of keys.
These comment fields are not allowed in any objects which permit user-defined keys (such as `"features"`).

Each manifest contains a top level object with the fields documented below; the most important ones are
[`"name"`](#name), the [version fields](#version-fields), and [`"dependencies"`](#dependencies):

### `"name"`

This is the name of your project! It must be formatted in a way that vcpkg understands - in other words,
it must be lowercase alphabetic characters, digits, and hyphens, and it must not start nor end with a hyphen.
For example, `Boost.Asio` might be given the name `boost-asio`.

This is a required field.

### Version fields

There is, at this point, only one version field - `"version-string"`. However, more will be added in the future.
You must have one (and only one) version field. There are different reasons to use each version field:

* `"version-string"` - used for packages that don't have orderable versions. This is pretty uncommon,
  but since we don't have any versioning constraints yet, this is the only one that you can use.

Additionally, the `"port-version"` field is used by registries of packages,
as a way to version "the package gotten from `vcpkg install`" differently from the upstream package version.
You shouldn't need to worry about this at all.

#### Additional version fields

**Experimental behind the `versions` feature flag**

See [versioning](versioning.md#version-schemes) for additional version types.

### `"description"`

This is where you describe your project. Give it a good description to help in searching for it!
This can be a single string, or it can be an array of strings;
in the latter case, the first string is treated as a summary,
while the remaining strings are treated as the full description.

### `"builtin-baseline"`

**Experimental behind the `versions` feature flag**

This field indicates the commit of vcpkg which provides global minimum version information for your manifest. It is required for top-level manifest files using versioning.

See also [versioning](versioning.md#builtin-baseline) for more semantic details.

### `"dependencies"`

This field lists all the dependencies you'll need to build your library (as well as any your dependents might need,
if they were to use you). It's an array of strings and objects:

* A string dependency (e.g., `"dependencies": [ "zlib" ]`) is the simplest way one can depend on a library;
  it means you don't depend on a single version, and don't need to write down any more information.
* On the other hand, an object dependency (e.g., `"dependencies": [ { "name": "zlib" } ]`)
  allows you to add that extra information.

#### Example:

```json
"dependencies": [
  {
    "name": "arrow",
    "default-features": false,
    "features": [ "json" ]
  },
  "boost-asio",
  "openssl",
  {
    "name": "picosha2",
    "platform": "!windows"
  }
]
```

#### `"name"` Field

The name of the dependency. This follows the same restrictions as the [`"name"`](#name) property for a project.

#### `"features"` and `"default-features"` Fields

`"features"` is an array of feature names which tell you the set of features that the
dependencies need to have at a minimum,
while `"default-features"` is a boolean that tells vcpkg whether or not to
install the features the package author thinks should be "most common for most people to use".

For example, `ffmpeg` is a library which supports many, many audio and video codecs;
however, for your specific project, you may only need mp3 encoding.
Then, you might just ask for:

```json
{
  "name": "ffmpeg",
  "default-features": false,
  "features": [ "mp3lame" ]
}
```

#### `"platform"` Field

The `"platform"` field defines the platforms where the dependency should be installed - for example,
you might need to use sha256, and so you use platform primitives on Windows, but `picosha2` on non-Windows platforms.

```json
{
  "name": "picosha2",
  "platform": "!windows"
}
```

This is a string field which takes boolean expressions of the form `<identifier>`,
`!expression`, `expression { & expression & expression...}`, and `expression { | expression | expression...}`,
along with parentheses to denote precedence.
For example, a dependency that's only installed on the Windows OS, for the ARM64 architecture,
and on Linux on x64, would be written `(windows & arm64) | (linux & x64)`.

The common identifiers are:

- The operating system: `windows`, `uwp`, `linux`, `osx` (includes macOS), `android`, `emscripten`
- The architecture: `x86`, `x64`, `wasm32`, `arm64`, `arm` (includes both arm32 and arm64 due to backwards compatibility)

although one can define their own.

#### `"version>="` Field

**Experimental behind the `versions` feature flag**

A minimum version constraint on the dependency.

This field specifies the minimum version of the dependency using a '#' suffix to denote port-version if non-zero.

See also [versioning](versioning.md#version-1) for more semantic details.

### `"overrides"`

**Experimental behind the `versions` feature flag**

This field enables version resolution to be ignored for certain dependencies and to use specific versions instead.

See also [versioning](versioning.md#overrides) for more semantic details.

#### Example:

```json
  "overrides": [
    {
      "name": "arrow", "version": "1.2.3", "port-version": 7
    }
  ]
```

### `"supports"`

If your project doesn't support common platforms, you can tell your users this with the `"supports"` field.
It uses the same platform expressions as [`"platform"`](#platform), from dependencies, as well as the
`"supports"` field of features.
For example, if your library doesn't support linux, you might write `{ "supports": "!linux" }`.


### `"features"` and `"default-features"`

The `"features"` field defines _your_ project's optional features, that others may either depend on or not.
It's an object, where the keys are the names of the features, and the values are objects describing the feature.
`"description"` is required,
and acts exactly like the [`"description"`](#description) field on the global package,
and `"dependencies"` are optional,
and again act exactly like the [`"dependencies"`](#dependencies) field on the global package.
There's also the `"supports"` field,
which again acts exactly like the [`"supports"`](#supports) field on the global package.

You also have control over which features are default, if a person doesn't ask for anything specific,
and that's the `"default-features"` field, which is an array of feature names.

#### Example:

```json
{
  "name": "libdb",
  "version": "1.0.0",
  "description": [
    "An example database library.",
    "Optionally can build with CBOR, JSON, or CSV as backends."
  ],
  "$default-features-explanation": "Users using this library transitively will get all backends automatically",
  "default-features": [ "cbor", "csv", "json" ],
  "features": {
    "cbor": {
      "description": "The CBOR backend",
      "dependencies": [
        {
          "$explanation": [
            "This is how you tell vcpkg that the cbor feature depends on the json feature of this package"
          ],
          "name": "libdb",
          "default-features": false,
          "features": [ "json" ]
        }
      ]
    },
    "csv": {
      "description": "The CSV backend",
      "dependencies": [
        "fast-cpp-csv-parser"
      ]
    },
    "json": {
      "description": "The JSON backend",
      "dependencies": [
        "jsoncons"
      ]
    }
  }
}
```

## Command Line Interface

**Experimental behind the `manifests` feature flag**

When invoked from any subdirectory of the directory containing `vcpkg.json`, `vcpkg install` with no package arguments
will install all manifest dependencies into `<directory containing vcpkg.json>/vcpkg_installed/`. Most of `vcpkg
install`'s classic mode parameters function the same in manifest mode.

### `--x-install-root=<path>`

**Experimental and may change or be removed at any time**

Specifies an alternate install location than `<directory containing vcpkg.json>/vcpkg_installed/`.

### `--triplet=<triplet>`

Specify the triplet to be used for installation.

Defaults to the same default triplet as in classic mode.

### `--x-feature=<feature>`

**Experimental and may change or be removed at any time**

Specify an additional feature from the `vcpkg.json` to install dependencies from.

### `--x-no-default-features`

**Experimental and may change or be removed at any time**

Disables automatic activation of all default features listed in the `vcpkg.json`.

### `--x-manifest-root=<path>`

**Experimental and may change or be removed at any time**

Specifies the directory containing `vcpkg.json`.

Defaults to searching upwards from the current working directory.

## CMake Integration

Our [CMake Integration](integration.md#cmake) will automatically detect a `vcpkg.json` manifest file in the same
directory as the top-level `CMakeLists.txt` (`${CMAKE_SOURCE_DIR}/vcpkg.json`) and activate manifest mode. Vcpkg will be
automatically bootstrapped if missing and invoked to install your dependencies into your local build directory
(`${CMAKE_BINARY_DIR}/vcpkg_installed`).

### Configuration

All vcpkg-affecting variables must be defined before the first `project()` directive, such as via the command line or
`set()` statements.

#### `VCPKG_TARGET_TRIPLET`

This variable controls which triplet dependencies will be installed for.

If unset, vcpkg will automatically detect an appropriate default triplet given the current compiler settings.

#### `VCPKG_HOST_TRIPLET`

This variable controls which triplet host dependencies will be installed for.

If unset, vcpkg will automatically detect an appropriate native triplet (x64-windows, x64-osx, x64-linux).

See also [Host Dependencies](host-dependencies.md).

#### `VCPKG_MANIFEST_MODE`

This variable controls whether vcpkg operates in manifest mode or in classic mode. To disable manifest mode even with a
`vcpkg.json`, set this to `OFF`.

Defaults to `ON` when `VCPKG_MANIFEST_DIR` is non-empty or `${CMAKE_SOURCE_DIR}/vcpkg.json` exists.

#### `VCPKG_MANIFEST_DIR`

This variable can be defined to specify an alternate folder containing your `vcpkg.json` manifest.

Defaults to `${CMAKE_SOURCE_DIR}` if `${CMAKE_SOURCE_DIR}/vcpkg.json` exists.

#### `VCPKG_MANIFEST_INSTALL`

This variable controls whether vcpkg will be automatically run to install your dependencies during your configure step.

Defaults to `ON` if `VCPKG_MANIFEST_MODE` is `ON`.

#### `VCPKG_BOOTSTRAP_OPTIONS`

This variable can be set to additional command parameters to pass to `./bootstrap-vcpkg` (run in automatic restore mode
if the vcpkg tool does not exist).

#### `VCPKG_OVERLAY_TRIPLETS`

This variable can be set to a list of paths to be passed on the command line as `--overlay-triplets=...`

#### `VCPKG_OVERLAY_PORTS`

This variable can be set to a list of paths to be passed on the command line as `--overlay-ports=...`

#### `VCPKG_MANIFEST_FEATURES`

This variable can be set to a list of features to treat as active when installing from your manifest.

For example, Features can be used by projects to control building with additional dependencies to enable tests or
samples:

```json
{
  "name": "mylibrary",
  "version": "1.0",
  "dependencies": [ "curl" ],
  "features": {
    "samples": {
      "description": "Build Samples",
      "dependencies": [ "fltk" ]
    },
    "tests": {
      "description": "Build Tests",
      "dependencies": [ "gtest" ]
    }
  }
}
```
```cmake
# CMakeLists.txt

option(BUILD_TESTING "Build tests" OFF)
if(BUILD_TESTING)
  list(APPEND VCPKG_MANIFEST_FEATURES "tests")
endif()

option(BUILD_SAMPLES "Build samples" OFF)
if(BUILD_SAMPLES)
  list(APPEND VCPKG_MANIFEST_FEATURES "samples")
endif()

project(myapp)

# ...
```

#### `VCPKG_MANIFEST_NO_DEFAULT_FEATURES`

This variable controls whether to automatically activate all default features in addition to those listed in
`VCPKG_MANIFEST_FEATURES`. If set to `ON`, default features will not be automatically activated.

Defaults to `OFF`.

#### `VCPKG_INSTALL_OPTIONS`

This variable can be set to a list of additional command line parameters to pass to the vcpkg tool during automatic
installation.

#### `VCPKG_PREFER_SYSTEM_LIBS`

This variable controls whether vcpkg will appends instead of prepends its paths to `CMAKE_PREFIX_PATH`, `CMAKE_LIBRARY_PATH` and `CMAKE_FIND_ROOT_PATH` so that vcpkg libraries/packages are found after toolchain/system libraries/packages.

Defaults to `OFF`.

#### `VCPKG_FEATURE_FLAGS`

This variable can be set to a list of feature flags to pass to the vcpkg tool during automatic installation to opt-in to
experimental behavior.

See the `--feature-flags=` command line option for more information.

## MSBuild Integration

To use manifests with MSBuild, first you need to use an [existing integration method](integration.md#with-msbuild).
Then, add a vcpkg.json above your project file (such as in the root of your source repository) and set the
property `VcpkgEnableManifest` to `true`. You can set this property via the IDE in `Project Properties -> Vcpkg -> Use
Vcpkg Manifest`.

As part of your project's build, vcpkg automatically be run and install any listed dependencies to `vcpkg_installed/`
adjacent to the `vcpkg.json` file; these files will then automatically be included in and linked to your MSBuild
projects.

Note: It is critical that all project files in a single build consuming the same `vcpkg.json` use the same triplet; if
you need to use different triplets for different projects in your solution, they must consume from different
`vcpkg.json` files.

### Known issues

* Visual Studio 2015 does not correctly track edits to the `vcpkg.json` and `vcpkg-configuration.json` files, and will
not respond to changes unless a `.cpp` is edited.

### MSBuild Properties

When using Visual Studio 2015 integration, these properties can be set in your project file before the

    <Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />

line, which unfortunately requires manual editing of the `.vcxproj` or passing on the msbuild command line with `/p:`.
With 2017 or later integration, These properties can additionally be set via the Visual Studio GUI under
`Project Properties -> Vcpkg` or via a common `.props` file imported between `Microsoft.Cpp.props` and
`Microsoft.Cpp.targets`.

#### `VcpkgEnabled` (Use Vcpkg)

This can be set to "false" to explicitly disable vcpkg integration for the project

#### `VcpkgTriplet` (Triplet)

This can be set to a custom triplet to use for integration (such as x64-windows-static)

#### `VcpkgHostTriplet` (Host Triplet)

This can be set to a custom triplet to use for resolving host dependencies.

If unset, this will default to the "native" triplet (x64-windows, x64-osx, x64-linux).

See also [Host Dependencies](host-dependencies.md).

#### `VcpkgAdditionalInstallOptions` (Additional Options)

When using a manifest, this option specifies additional command line flags to pass to the underlying vcpkg tool
invocation. This can be used to access features that have not yet been exposed through another option.

#### `VcpkgConfiguration` (Vcpkg Configuration)

If your configuration names are too complex for vcpkg to guess correctly, you can assign this property to `Release` or
`Debug` to explicitly tell vcpkg what variant of libraries you want to consume.

#### `VcpkgEnableManifest` (Use Vcpkg Manifest)

This property must be set to true in order to consume from a local vcpkg.json file. If set to false, any local
vcpkg.json files will be ignored. This will default to true in the future.

#### `VcpkgManifestInstall` (Install Vcpkg Dependencies)

*(Requires `Use Vcpkg Manifest` set to `true`)*

This property can be set to "false" to disable automatic dependency restoration on project build. Dependencies can be
manually restored via the vcpkg command line.

#### `VcpkgInstalledDir` (Installed Directory)

This property defines the location where headers and binaries are consumed from. In manifest mode, this directory is
created and populated based on your manifest.
