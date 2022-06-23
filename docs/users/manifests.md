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

Check out the [manifest cmake example](../examples/manifest-mode-cmake.md) for an example project using CMake and
manifest mode.

## Table of Contents

- [Simple Example Manifest](#simple-example-manifest)
- [Manifest Syntax Reference](#manifest-syntax-reference)
  - [`"name"`](#name)
  - [Version Fields](#version-fields)
  - [`"description"`](#description)
  - [`"builtin-baseline"`](#builtin-baseline)
  - [`"dependencies"`](#dependencies)
    - [`"name"`](#dependencies-name)
    - [`"default-features"`](#dependencies-default-features)
    - [`"features"`](#dependencies-features)
    - [`"platform"`](#platform)
    - [`"version>="`](#version-gt)
  - [`"overrides"`](#overrides)
  - [`"supports"`](#supports)
  - [`"features"`](#features)
  - [`"default-features"`](#default-features)

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

<a id="name"></a>

### `"name"`

This is the name of your project! It must be formatted in a way that vcpkg understands - in other words,
it must be lowercase alphabetic characters, digits, and hyphens, and it must not start nor end with a hyphen.
For example, `Boost.Asio` might be given the name `boost-asio`.

This is a required field.

### Version Fields

There are four version field options, depending on how the port orders its
releases.

* [`"version"`](versioning.md#version) - Generic, dot-separated numeric
  sequence.
* [`"version-semver"`](versioning.md#version-semver) - [Semantic Version
  2.0.0](https://semver.org/#semantic-versioning-specification-semver)
* [`"version-date"`](versioning.md#version-date) - Used for packages which do
  not have numeric releases (for example, Live-at-HEAD). Matches `YYYY-MM-DD`
  with optional trailing dot-separated numeric sequence.
* [`"version-string"`](versioning.md#version-string) - Used for packages that
  don't have orderable versions. This should be rarely used, however all ports
  created before the other version fields were introduced use this scheme.

Additionally, the optional `"port-version"` field is used to indicate revisions
to the port with the same upstream source version. For pure consumers, this
field should not be used.

See [versioning](versioning.md#version-schemes) for more details.

<a id="description"></a>

### `"description"`

This is where you describe your project. Give it a good description to help in searching for it!
This can be a single string, or it can be an array of strings;
in the latter case, the first string is treated as a summary,
while the remaining strings are treated as the full description.

<a id="builtin-baseline"></a>

### `"builtin-baseline"`

This field indicates the commit of vcpkg which provides global minimum version
information for your manifest. It is required for top-level manifest files using
versioning.

This is a convenience field that has the same semantic as replacing your default
registry in
[`vcpkg-configuration.json`](registries.md#configuration-default-registry).

See [versioning](versioning.md#builtin-baseline) for more semantic details.

<a id="dependencies"></a>

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

<a id="dependencies-name"></a>

#### `"name"` Field

The name of the dependency. This follows the same restrictions as the [`"name"`](#name) property for a project.

<a id="dependencies-default-features"></a>
<a id="dependencies-features"></a>

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

<a id="platform"></a>

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

<a id="version-gt"></a>

#### `"version>="` Field

A minimum version constraint on the dependency.

This field specifies the minimum version of the dependency, optionally using a
`#N` suffix to denote port-version if non-zero.

See also [versioning](versioning.md#version-1) for more semantic details.

<a id="overrides"></a>

### `"overrides"`

This field pins exact versions for individual dependencies.

`"overrides"` from transitive manifests (i.e. from dependencies) are ignored.

See also [versioning](versioning.md#overrides) for more semantic details.

#### Example:

```json
  "overrides": [
    {
      "name": "arrow", "version": "1.2.3", "port-version": 7
    }
  ]
```

<a id="supports"></a>

### `"supports"`

If your project doesn't support common platforms, you can tell your users this with the `"supports"` field.
It uses the same platform expressions as [`"platform"`](#platform), from dependencies, as well as the
`"supports"` field of features.
For example, if your library doesn't support linux, you might write `{ "supports": "!linux" }`.

<a id="default-features"></a>
<a id="features"></a>

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
