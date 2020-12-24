# Manifest files - `vcpkg.json`

The `vcpkg.json` file contains metadata about the port.
It's a JSON file, and replaces the existing CONTROL file metadata structure.
It must have a top level object, and all fields are case sensitive.

## Examples:

The most important fields in a manifest, the ones which are required for all ports,
are the `"name"` field, and a version field (for now, just `"version-string"`).
There's more information about these fields below.

```json
{
  "name": "ace",
  "version-string": "6.5.5"
}
```

```json
{
  "name": "vtk",
  "version-string": "8.2.0",
  "port-version": 2,
  "description": "Software system for 3D computer graphics, image processing, and visualization",
  "dependencies": [
    {
      "name": "atlmfc",
      "platform": "windows"
    },
    "double-conversion",
    "eigen3",
    "expat",
    "freetype",
    "glew",
    "hdf5",
    "jsoncpp",
    "libharu",
    "libjpeg-turbo",
    "libpng",
    "libtheora",
    "libxml2",
    "lz4",
    "netcdf-c",
    "proj4",
    "pugixml",
    "sqlite3",
    "tiff",
    "zlib"
  ]
}
```

## Fields

### `"name"`
The name of the port.

When adding new ports be aware that the name may conflict with other projects that are not a part of vcpkg.  For example `json` conflicts with too many other projects so you should add a scope to the name such as `taocpp-json` to make it unique.  Verify there are no conflicts on a search engine as well as on other package collections.

Package collections to check for conflicts:

+ [Repology](https://repology.org/projects/)
+ [Debian packages](https://www.debian.org/distrib/packages)
+ [Packages search](https://pkgs.org/)

A name must be an identifier: i.e., it must only consist of lowercase ascii alphabetic characters,
numbers, and hyphens, and it must not begin nor end with a hyphen.

### Version fields

The library version. There is currently only one kind of version, a `"version-string"` -
however, more version kinds will be added later. Additionally,
`"port-version"` is used to differentiate between port changes that don't change the underlying library version.

#### `"version-string"`

This field is an ascii string, and may contain alphanumeric characters, `.`, `_`, or `-`. No attempt at ordering versions is made; all versions are treated as byte strings and are only evaluated for equality.

For tagged-release ports, we follow the following convention:

1. If the library follows a scheme like `va.b.c`, we remove the leading `v`. In this case, it becomes `a.b.c`.
2. If the library includes its own name in the version like `curl-7_65_1`, we remove the leading name: `7_65_1`
3. If the library is versioned by dates, format the resulting version string just like the upstream library;
   for example, Abseil formats their dates `lts_2020_02_25`, so the `"version-string"` should be `"lts_2020_02_25"`.

For rolling-release ports, we use the date that the _commit was accessed by you_, formatted as `YYYY-MM-DD`. Stated another way: if someone had a time machine and went to that date, they would see this commit as the latest master.

For example, given:
1. The latest commit was made on 2019-04-19
2. The current version string is `2019-02-14`
3. Today's date is 2019-06-01.

Then if you update the source version today, you should give it version `2019-06-01`.

#### `"port-version"`

The version of the port, aside from the library version.

This field is a non-negative integer.
It allows one to version the port file separately from the version of the underlying library;
if you make a change to a port, without changing the underlying version of the library,
you should increment this field by one (starting at `0`, which is equivalent to no `"port-version"` field).
When the version of the underlying library is upgraded,
this field should be set back to `0` (i.e., delete the `"port-version"` field).

#### Examples:
```json
{
  "version": "1.0.5",
  "port-version": 2
}
```

```json
{
  "version": "2019-03-21"
}
```

### `"description"`

A description of the library.

This field can either be a single string, which should be a summary of the library,
or can be an array, with the first line being a summary and the remaining lines being the detailed description -
one string per line.

#### Examples:
```json
{
  "description": "C++ header-only JSON library"
}
```
```json
{
  "description": [
    "Mosquitto is an open source message broker that implements the MQ Telemetry Transport protocol versions 3.1 and 3.1.1.",
    "MQTT provides a lightweight method of carrying out messaging using a publish/subscribe model."
    "This makes it suitable for 'machine to machine' messaging such as with low power sensors or mobile devices such as phones, embedded computers or microcontrollers like the Arduino."
  ]
}
```

### `"homepage"`

The URL of the homepage for the library where a user is able to find additional documentation or the original source code.

### `"documentation"`

The URL where a user would be able to find official documentation for the library. Optional.

### `"maintainers"`

A list of strings that define the set of maintainers of a package.
It's recommended that these take the form of `Givenname Surname <email>`,
but this field is not checked for consistency.

Optional.

#### Example:
```json
{
  "homepage": "https://github.com/microsoft/vcpkg"
}
```

### `"dependencies"`

An array of ports the library has a dependency on.

vcpkg does not distinguish between build-only dependencies and runtime dependencies.
The complete list of dependencies needed to successfully use the library should be specified.

For example: websocketpp is a header only library, and thus does not require any dependencies at install time.
However, downstream users need boost and openssl to make use of the library.
Therefore, websocketpp lists boost and openssl as dependencies.

Each dependency may be either an identifier, or an object.
For many dependencies, just listing the name of the library should be fine;
however, if one needs to add extra information to that dependency, one may use the dependency object.
For a dependency object, the `"name"` field is used to designate the library;
for example the dependency object `{ "name": "zlib" }` is equivalent to just writing `"zlib"`.

If the port is dependent on optional features of another library,
those can be specified using the `"features"` field of the dependency object.
If the port does not require any features from the dependency,
this should be specifed with the `"default-features"` fields set to `false`.

Dependencies can also be filtered based on the target triplet to support differing requirements.
These filters use the same syntax as the `"supports"` field below,
and are specified in the `"platform"` field.

#### Example:
```json
{
  "dependencies": [
    {
      "name": "curl",
      "default-features": false,
      "features": [
        "winssl"
      ],
      "platform": "windows"
    },
    {
      "name": "curl",
      "default-features": false,
      "features": [
        "openssl"
      ],
      "platform": "!windows"
    },
    "rapidjson"
  ]
}
```

### `"features"`

Multiple optional features can be specified in manifest files, in the `"features"` object field.
This field is a map from the feature name, to the feature's information.
Each one must have a `"description"` field, and may also optionally have a `"dependencies"` field.

A feature's name must be an identifier -
in other words, lowercase alphabetic characters, digits, and hyphens,
neither starting nor ending with a hyphen.

A feature's `"description"` is a description of the feature,
and is the same kind of thing as the port `"description"` field.

A feature's `"dependencies"` field contains the list of extra dependencies required to build and use this feature;
this field isn't required if the feature doesn't require any extra dependencies.
On installation the dependencies from all selected features are combined to produce the full dependency list for the build.

#### Example:

```json
{
  "name": "vtk",
  "version-string": "8.2.0",
  "port-version": 2,
  "description": "Software system for 3D computer graphics, image processing, and visualization",
  "dependencies": [
    {
      "name": "atlmfc",
      "platform": "windows"
    },
    "double-conversion",
    "eigen3",
    "expat",
    "freetype",
    "glew",
    "hdf5",
    "jsoncpp",
    "libharu",
    "libjpeg-turbo",
    "libpng",
    "libtheora",
    "libxml2",
    "lz4",
    "netcdf-c",
    "proj4",
    "pugixml",
    "sqlite3",
    "tiff",
    "zlib"
  ],
  "features": {
    "mpi": {
      "description": "MPI functionality for VTK",
      "dependencies": [
        {
          "name": "hdf5",
          "features": [
            "parallel"
          ]
        },
        "mpi"
      ]
    },
    "openvr": {
      "description": "OpenVR functionality for VTK",
      "dependencies": [
        "openvr",
        "sdl2"
      ]
    },
    "python": {
      "description": "Python functionality for VTK",
      "dependencies": [
        "python3"
      ]
    },
    "qt": {
      "description": "Qt functionality for VTK",
      "dependencies": [
        "qt5"
      ]
    }
  }
}
```

### `"default-features"`

An array of feature names that the library uses by default, if nothing else is specified.

#### Example:
```json
{
  "default-features": [
    "kinesis"
  ],
  "features": {
    "dynamodb": {
      "description": "Build dynamodb support",
      "dependencies": [
        "dynamodb"
      ]
    },
    "kinesis": {
      "description": "build kinesis support"
    }
  }
}
```

### `"supports"`

A string, formatted as a platform expression,
that evaluates to true when the port should build successfully for a triplet.

This field is used in the CI testing to skip ports,
and warns users in advance that a given install tree is not expected to succeed.
Therefore, this field should be used optimistically;
in cases where a port is expected to succeed 10% of the time, it should still be marked "supported".

The grammar for this top-level platform expression, in [EBNF], is as follows:

```ebnf
whitespace-character =
| ? U+0009 "CHARACTER TABULATION" ?
| ? U+000A "LINE FEED" ?
| ? U+000D "CARRIAGE RETURN" ?
| ? U+0020 "SPACE" ? ;
optional-whitespace = { whitespace-character } ;

lowercase-alpha =
| "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m"
| "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" ;
digit =
| "0" | "1" | "2" | "3" | "4"
| "5" | "6" | "7" | "8" | "9" ;
identifier-character =
| lowercase-alpha
| digit ;

platform-expression =
| platform-expression-not
| platform-expression-and
| platform-expression-or ;

platform-expression-identifier = 
| identifier-character, { identifier-character }, optional-whitespace ;

platform-expression-simple =
| platform-expression-identifier
| "(", optional-whitespace, platform-expression, ")", optional-whitespace ;

platform-expression-not =
| platform-expression-simple
| "!", optional-whitespace, platform-expression-simple ;

platform-expression-and =
| platform-expression-not, { "&", optional-whitespace, platform-expression-not } ;

platform-expression-or =
| platform-expression-not, { "|", optional-whitespace, platform-expression-not } ;

top-level-platform-expression = optional-whitespace, platform-expression ;
```

Basically, there are four kinds of expressions -- identifiers, negations, ands, and ors.
Negations may only negate an identifier or a grouped expression.
Ands and ors are a list of `&` or `|` separated identifiers, negated expressions, and grouped expressions.
One may not mix `&` and `|` without parentheses for grouping.

These predefined identifier expressions are computed from standard triplet settings:
- `x64` - `VCPKG_TARGET_ARCHITECTURE` == `"x64"`
- `x86` - `VCPKG_TARGET_ARCHITECTURE` == `"x86"`
- `arm` - `VCPKG_TARGET_ARCHITECTURE` == `"arm"` or `VCPKG_TARGET_ARCHITECTURE` == `"arm64"`
- `arm64` - `VCPKG_TARGET_ARCHITECTURE` == `"arm64"`
- `windows` - `VCPKG_CMAKE_SYSTEM_NAME` == `""` or `VCPKG_CMAKE_SYSTEM_NAME` == `"WindowsStore"`
- `mingw` - `VCPKG_CMAKE_SYSTEM_NAME` == `"MinGW"`
- `uwp` - `VCPKG_CMAKE_SYSTEM_NAME` == `"WindowsStore"`
- `linux` - `VCPKG_CMAKE_SYSTEM_NAME` == `"Linux"`
- `osx` - `VCPKG_CMAKE_SYSTEM_NAME` == `"Darwin"`
- `android` - `VCPKG_CMAKE_SYSTEM_NAME` == `"Android"`
- `static` - `VCPKG_LIBRARY_LINKAGE` == `"static"`
- `wasm32` - `VCPKG_TARGET_ARCHITECTURE` == `"wasm32"`
- `emscripten` - `VCPKG_CMAKE_SYSTEM_NAME` == `"Emscripten"`

These predefined identifier expressions can be overridden in the triplet file,
via the [`VCPKG_DEP_INFO_OVERRIDE_VARS`](../users/triplets.md) option,
and new identifier expressions can be added via the same mechanism.

This field is optional and defaults to true.

> Implementers' Note: these terms are computed from the triplet via the `vcpkg_get_dep_info` mechanism.

[EBNF]: https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form

#### Example:
```json
{
  "supports": "!uwp & !(arm & !arm64)"
}
```

This means "doesn't support uwp, nor arm32 (but does support arm64)".
