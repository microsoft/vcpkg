# Manifest Mode

vcpkg has two modes of operation - classic mode and manifest mode.

In classic mode, vcpkg produces an "installed" tree,
whose contents are changed by explicit calls to `vcpkg install` or `vcpkg remove`.
The installed tree is intended for consumption by any number of projects:
for example, installing a bunch of libraries and then using those libraries from Visual Studio,
without additional configuration.
Because the installed tree is not associated with an individual project,
it's similar to tools like `brew` or `apt`,
except that the installed tree is vcpkg-installation-local,
rather than global to a system or user.

In manifest mode, an installed tree is associated with a particular project rather than the vcpkg installation.
The set of installed ports is controlled by editing the project's "manifest file",
and the installed tree is placed in the project directory or build directory.
This mode acts more similarly to language package managers like Cargo, or npm. 
We recommend using this manifest mode whenever possible,
because it allows one to encode a project's dependencies explicitly in a project file,
rather than in the documentation, making your project much easier to consume.

Manifest mode is in beta, but one can use it from the CMake integration,
which will be stable when used via things like `find_package`.
This is the recommended way to use manifest mode.

In this document, we have basic information on [Writing a Manifest](#writing-a-manifest),
the [vcpkg Command Line Interface](#command-line-interface),
and a little more information on [CMake](#cmake-integration) integration.

Check out the [manifest cmake example](../examples/manifest-mode-cmake.md) for an example project using CMake and
manifest mode.

## Writing a Manifest

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

### `"description"`

This is where you describe your project. Give it a good description to help in searching for it!
This can be a single string, or it can be an array of strings;
in the latter case, the first string is treated as a summary,
while the remaining strings are treated as the full description.

### `"dependencies"`

This field lists all the dependencies you'll need to build your library (as well as any your dependents might need,
if they were to use you). It's an array of strings and objects:

* A string dependency (e.g., `"dependencies": [ "zlib" ]`) is the simplest way one can depend on a library;
  it means you don't depend on a single version, and don't need to write down any more information.
* On the other hand, an object dependency (e.g., `"dependencies": [ { "name": "zlib" } ]`)
  allows you to add that extra information.

An object dependency can have the following fields:

#### `"name"`

The name of the dependency. This follows the same restrictions as the [`"name"`](#name) property for a project.

#### `"features"` and `"default-features"`

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

#### `"platform"`

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

#### Example:

```json
{
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
}
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

```
{
  "name": "libdb",
  "description": [
    "An example database library.",
    "Optionally uses one of CBOR, JSON, or CSV as a backend."
  ],
  "default-features": [ "cbor", "csv", "json" ],
  "features": {
    "cbor": {
      "description": "The CBOR backend",
      "dependencies": [
        {
          "$explanation": [
            "This is currently how you tell vcpkg that the cbor feature depends on the json feature of this package",
            "We're looking into making this easier"
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
    "gui": {
      "description": "The GUI libdb database viewer.",
      "supports": "windows | osx"
    }
    "json": {
      "description": "The JSON backend",
      "dependencies": [
        "jsoncons"
      ]
    },
  }
}
```

## Command Line Interface

The command line interface around the new manifest mode is pretty simple.
There's only one command that one really needs to worry about, `vcpkg install`,
although `vcpkg search` is still useful.
Since manifest mode is still in beta, you'll need to pass a feature flag: `manifests`.
There are a few ways to pass this feature flag:

* `--feature-flags` option: On any vcpkg command, you can pass `--feature-flags=manifests`
* `VCPKG_FEATURE_FLAGS` environment variable: one can set the environment variable `VCPKG_FEATURE_FLAGS` to
  `manifests`.

### `vcpkg install`

Once one has written a manifest file,
they can run `vcpkg install` in any subdirectory of the directory containing `vcpkg.json`.
It will install all of the dependencies for the default triplet into
`<directory containing vcpkg.json>/vcpkg_installed`.
If you want to switch the triplet (for example, this is very common on windows, where the default triplet is x86-windows, not x64-windows),
you can pass it with the `--triplet` option: `vcpkg install --triplet x64-windows` (or whatever).
Then, vcpkg will install all the dependencies, and you're ready to go!

## CMake Integration

The CMake integration acts exactly like the existing CMake integration.
One passes the toolchain file, located at `[vcpkg root]/scripts/buildsystems/vcpkg.cmake`,
to the CMake invocation via the `CMAKE_TOOLCHAIN_FILE` variable.
Then, CMake will install all dependencies into the build directory, and you're good!
It ends up that you only have to run CMake, and vcpkg is called only as part of the build process.
Unlike bare vcpkg, the feature flag is not required,
since the CMake integration won't break as long as you depending on the exact naming of vcpkg's installed directory.

### Example:

```
> cmake -B builddir -S . -DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
> cmake --build builddir
```

with a `vcpkg.json` in the same directory as `CMakeLists.txt` should Just Work!
