# Manifests -- `vcpkg.json`

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

**Up-to-date documentation is available at [Manifests](../users/manifests.md).**

For many other language package managers, there exists a way of writing one's dependencies in a declarative
manifest format; we want something similar for vcpkg. What follows is the specification of that feature;
this should mean that vcpkg becomes far more user and enterprise-friendly, and is additionally an important
first step for versioning and package federation. Our primary concern, beyond implementability, is ease-of-use;
it is important that using this feature is all of:

* Easy for existing users
* Easy for new users to set up
* Easy to extend later for new features like versioning and federation
* _Declarative_, not _Imperative_.

## Reasoning

### Why JSON?

We choose JSON for five main reasons:

* Everybody knows JSON, and if one doesn't, it's really easy to learn
* Every tool supports JSON in the standard library, or in a commonly used support library
  * This means writing tooling should be trivial in any language one is comfortable with
  * Most configuration formats don't have a COBOL implementation 😉
* Specified in an international standard
  * There is _one_ right way to parse JSON
  * There are no ambiguities of what the parse tree _should_ be
* Simple and secure
  * Unlike YAML, for example, there's no weird ACE issues
  * Easy to write a parser -- important since we can't depend on external libraries
* Schemas are almost a necessity

Some have suggested allowing comments or commas in our parser; we chose to use JSON proper
rather than JSON5 or JSON with comments because JSON is the everywhere-supported international
standard. That is not necessarily true of JSON with comments. Additionally, if one needs
to write a comment, they can do so via `"$reason"` or `"$comment"` fields.

## Specification

A manifest file shall have the name `vcpkg.json`, and shall be in the root directory of a package.
It also replaces CONTROL files, though existing CONTROL files will still be
supported; there will be no difference between ports and packages, except
that packages do not need to supply portfile.cmake (eventually we would like
to remove the requirement of portfile.cmake for ports that already use
CMake).

The specification uses definitions from the [Definitions](#definitions) section in order
to specify the shape of a value. Note that any object may contain any directives, written as
a field key that starts with a `$`; these directives shall be ignored by `vcpkg`. Common
directives may include `"$schema"`, `"$comment"`, `"$reason"`.

A manifest must be a top-level object, and must have at least:

* `"name"`: a `<package-name>`
* One (and only one) of the following version fields:
  * `"version-string"`: A `string`. Has no semantic meaning.
    Equivalent to `CONTROL`'s `Version:` field.
  * Other version fields will be defined by the Versions RFC

The simplest vcpkg.json looks like this:

```json
{
  "name": "mypackage",
  "version-string": "0.1.0-dev"
}
```

Additionally, it may contain the following properties:
* `"port-version"`: A non-negative integer. If this field doesn't exist, it's assumed to be `0`.
  * Note that this is a change from existing CONTROL files, where versions were a part of the version string
* `"maintainers"`: An array of `string`s which contain the authors of a package
  * `"maintainers": [ "Nicole Mazzuca <nicole@example.com>", "שלום עליכם <shalom@example.com>" ]`
* `"description"`: A string or array of strings containing the description of a package
  * `"description": "mypackage is a package of mine"`
* `"homepage"`: A url which points to the homepage of a package
  * `"homepage": "https://github.com/strega-nil/mypackage"`
* `"documentation"`: A url which points to the documentation of a package
  * `"documentation": "https://readthedocs.io/strega-nil/mypackage"`
* `"license"`: A `<license-string>`
  * `"license": "MIT"`
* `"dependencies"`: An array of `<dependency>`s
* `"dev-dependencies"`: An array of `<dependency>`s which are required only for developers (testing and the like)
* `"features"`: An array of `<feature>`s that the package supports
* `"default-features"`: An array of `<identifier>`s that correspond to features, which will be used by default.
* `"supports"`: A `<platform-expression>`
  * `"supports": "windows & !arm"`

Any properties which are not listed, and which do not start with a `$`,
will be warned against and are reserved for future use.

The following is an example of an existing port CONTROL file rewritten as a vcpkg.json file:

```
Source: pango
Version: 1.40.11-6
Homepage: https://ftp.gnome.org/pub/GNOME/sources/pango/
Description: Text and font handling library.
Build-Depends: glib, gettext, cairo, fontconfig, freetype, harfbuzz[glib] (!(windows&static)&!osx)
```

```json
{
  "name": "pango",
  "version-string": "1.40.11",
  "port-version": 6,
  "homepage": "https://ftp.gnome.org/pub/GNOME/sources/pango/",
  "description": "Text and font handling library.",
  "dependencies": [
    "glib",
    "gettext",
    "cairo",
    "fontconfig",
    "freetype",
    {
      "name": "harfbuzz",
      "features": [ "glib" ],
      "platform": "!(windows & static) & !osx"
    }
  ]
}
```

## Behavior of the Tool

There will be two "modes" for vcpkg from this point forward: "classic", and "manifest".
The former will act exactly like the existing vcpkg workflow, so as to avoid breaking
anyone. The latter will be the mode only when the user either:

* Passes `--manifest-root=<directory>` (initially, `x-manifest-root`)
* Runs `vcpkg` in a directory that contains a file named `vcpkg.json`, or in a
  child directory of a directory containing `vcpkg.json`.
  * For this, initially vcpkg will warn that the behavior will change in the
    future, and simply run in classic mode, unless the feature flag `manifests` is
    passed via:
    * The environment variable `VCPKG_FEATURE_FLAGS`
    * The option `--feature-flags`
      * (e.g., `--feature-flags=binarycaching,manifests`)
    * If someone wants to use classic mode and silence the warning, they can add the
      `-manifests` feature flag to disable the mode.

When in "manifest" mode, the `installed` directory will be changed to
`<manifest-root>/vcpkg_installed` (name up for bikeshedding).
The following commands will change behavior:

* `vcpkg install` without any port arguments will install the dependencies listed in
  the manifest file, and will remove any dependencies
  which are no longer in the dependency tree implied by the manifest file.
* `vcpkg install` with port arguments will give an error.

The following commands will not work in manifest mode, at least initially:

* `vcpkg x-set-installed`: `vcpkg install` serves the same function
* `vcpkg remove`
* `vcpkg export`

We may add these features back for manifest mode once we understand how best to
implement them.

### Behavior of the Toolchain

Mostly, the toolchain file stays the same; however, we shall add
two public options:

```cmake
VCPKG_MANIFEST_MODE:BOOL=<we found a manifest>
VCPKG_MANIFEST_INSTALL:BOOL=ON
```

The first option either explicitly turns on, or off, manifest mode;
otherwise, we default to looking for a manifest file in the directory
tree upwards from the source directory.

The `VCPKG_MANIFEST_INSTALL` option tells the toolchain whether to
install the packages or not -- if you wish to install the manifest
dependencies manually, you can set this to off, and we also turn it
off for packages installed by vcpkg.

Additionally, if `-manifests` is set in the feature flags environment
variable, we turn off manifest mode in the toolchain, and we act like
the classic toolchain.

### Example - CMake Integration

An example of using the new vcpkg manifests feature for a new
project follows:

The filesystem structure should look something like:

```
example/
  src/
    main.cxx
  CMakeLists.txt
  vcpkg.json
```

Then, `main.cxx` might look like:

```cpp
#include <fmt/format.h>

int main() {
  fmt::print("Hello, {}!", "world");
}
```

Therefore, in `vcpkg.json`, we'll need to depend on `fmt`:

```json
{
  "name": "example",
  "version-string": "0.0.1",
  "dependencies": [
    "fmt"
  ]
}
```

Then, let's write our `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.14)

project(example CXX)

add_executable(example src/main.cxx)

find_package(fmt REQUIRED)

target_link_libraries(example
  PRIVATE
    fmt::fmt)
```

And finally, to configure and build:

```sh
$ cd example
$ cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
... configuring and installing...
$ cmake --build build
```

and we're done! `fmt` will get installed into
`example/build/vcpkg_installed`, and we can run our executable with:

```sh
$ build/example
Hello, world!
```

## Definitions

* `<identifier>`: A `string` which:
  * Is entirely ASCII
  * Contains only lowercase alphabetic characters, digits, and hyphen-minus
  * Does not have multiple consecutive hyphens
  * Does not begin nor end with a hyphen
  * Is not a Windows filesystem reserved name
  * Is not a vcpkg reserved name: "default" or "core".
  * In other words, it must follow the regex `[a-z0-9]+(-[a-z0-9]+)*`, and must not be any of:
    * `{ prn, aux, nul, con, lpt[1-9], com[1-9], core, default }`
* `<package-name>`: A `string` consisting of a non-zero number of `<identifier>`s, separated by `.`.
  * `a.b.c` is valid
  * `a` is valid
  * `a/b` is not valid
  * `Boost.Beast` is not valid, but `boost.beast` is
* `<dependency>`: Either a `<package-name>`, or an object:
  * A dependency always contains the following:
    * `"name"`: A `<package-name>`
    * Optionally, `"features"`: an array of `<identifier>`s corresponding to features in the package.
    * Optionally, `"default-features"`: a `boolean`. If this is false, then don't use the default features of the package; equivalent to core in existing CONTROL files. If this is true, do the default thing of including the default features.
    * Optionally, `"platform"`: a `<platform-expression>`
  * `<dependency.port>`: No extra fields are required.
* `<license-string>`: An SPDX license expression at version 3.9.
* `<platform-expression>`: A specification of a set of platforms; used in platform-specific dependencies and supports fields. A string that is parsed as follows:
  * `<platform-expression>`:
    * `<platform-expression.not>`
    * `<platform-expression.and>`
    * `<platform-expression.or>`
  * `<platform-expression.simple>`:
    * `( <platform-expression> )`
    * `<platform-expression.identifier>`
  * `<platform-expression.identifier>`:
    * regex: `/^[a-z0-9]+$/`
  * `<platform-expression.not>`:
    * `<platform-expression.simple>`
    * `! <platform-expression.simple>`
  * `<platform-expression.and>`
    * `<platform-expression.not>`
    * `<platform-expression.and> & <platform-expression.not>`
  * `<platform-expression.or>`
    * `<platform-expression.not>`
    * `<platform-expression.or> | <platform-expression.not>`
* `<feature>`: An object containing the following:
  * `"name"`: An `<identifier>`, the name of the feature
  * `"description"`: A `string` or array of `string`s, the description of the feature
  * Optionally, `"dependencies"`: An array of `<dependency>`s, the dependencies used by this feature
