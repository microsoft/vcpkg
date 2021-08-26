# Versioning Specification 

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

**Up-to-date documentation is available at [Versioning](../users/versioning.md).**

## Glossary
Some of the terms used in this document have similar meaning when discussed by the community, and because of that, they can cause confusion and ambiguity. To solve this issue, we will assign specific meaning to these terms and try to keep a consistent usage through the document.

**Library**: A piece of software (source code, binary files, documentation, license, etc.) that is intended to be reused by other software.

**Package**: A package can contain a library, collection of libraries, build scripts, software tools, or other components necessary for their use. The goal of vcpkg is to facilitate the installation of these packages in the user's environment.

**Port**: A vcpkg specific term, a port contains:

* Metadata about a package: package version, supported features, dependencies, etc.
* Instructions to acquire, build if necessary, and install the package.

## 1 Enabling package versioning
On launch, the versioning feature will be disabled by default. Users can enable this feature by setting the `versions` feature flag.

Example:
```
vcpkg --feature-flags=versions install
```

### 1.1 Proposed experience
This feature requires the use of manifests to declare project dependencies. To allow versioning, the following features are added to manifests:

* Ability to declare a package's versioning scheme.
* Ability to declare version constraints on dependencies.
* Ability for a top-level manifest to override all other version constraints.
* Ability to declare a baseline for all versions.

Example: A manifest (`vcpkg.json`) using versioning features.
```json
{
  "name": "versions-test",
  "version": "1.0.0",
  "dependencies": ["fmt", {"name": "zlib", "version>=": "1.2.11"}],
  "$x-default-baseline": "9fd3bd594f41afb8747e20f6ac9619f26f333cbe"
}
```

The example above shows some new manifest properties:
* `"version"`: Declares a version using a dot-separated versioning scheme (`1.0.0`).
* `"version>="`: Declares a minimum version constraint on package `zlib`.
* `"$x-default-baseline"`: Declares a baseline version for all packages.

All these new features are described in more detail in this document.

## 2 Specifying package versions
Through the years, C++ software authors have adopted multiple versioning schemes and practices that sometimes conflict between each other. On vcpkg, the most recurrent versioning schemes found are:
*	Semantic versions
*	Dates
*	Repository commits
*	Arbitrary strings

For vcpkg to achieve wide adoption and compatibility with existing projects, it is important that we respect the versioning schemes used by each of the packages contained in our ports catalog.

### 2.1 Port versions
Package versioning information is divided in two parts: a version string and a port version. 
Port versions are a concept exclusive to vcpkg, they do not form part of a package’s upstream. But allow for versioning of the vcpkg ports themselves. 

Packages can also include the port version as part of a version constraint by using the “port-version” property on their dependencies.

#### `port-version`

An integer value that increases each time a vcpkg-specific change is made to the port.  

The rules for port versions are:
* Start at 0 for the original version of the port,
* increase by 1 each time a vcpkg-specific change is made to the port that does not increase the version of the package,
* and reset to 0 each time the version of the package is updated.

Defaults to 0 if omitted.

### 2.2 Package versions
Versions are an important part of a package’s upstream metadata. Ports in vcpkg should attempt to follow the versioning conventions used by the package’s authors. For that reason, when declaring a package’s version the appropriate scheme should be used.

Each versioning scheme defines their own rules on what is a valid version string and more importantly the rules for how to sort versions using the same scheme.

The versioning schemes understood by vcpkg are:

Manifest property | Versioning scheme
------------------|------------------------------------
`version`         | For dot-separated numeric versions
`version-semver`  | For SemVer compliant versions
`version-date`    | For dates in the format YYYY-MM-DD
`version-string`  | For arbitrary strings

A manifest must contain only one version declaration.

#### `version`
Accepts version strings that follow a relaxed, dot-separated-, semver-like scheme.

The version is logically composed of dot-separated (`.`) numeric sections. Each section must contain an integer positive number with no leading zeroes.

The regex pattern for this versioning scheme is: `(0|[1-9]\d*)(\.(0|[1-9]\d*))*`

_Sorting behavior_: When comparing two versions, each section is compared from left to right by their numeric value, until the first difference is found. A version with the smallest set of sections takes precedence over another with a larger set of sections, given that all their preceding sections compare equally.

Example:  
`0` < `0.1` < `0.1.0` < `1` < `1.0.0` < `1.0.1` < `1.1`< `2.0.0`

#### `version-semver`
Accepts version strings that follow semantic versioning conventions as described in the [semantic versioning specification](https://semver.org/#semantic-versioning-specification-semver).

_Sorting behavior_: Strings are sorted following the rules described in the semantic versioning specification.

Example: 
`1.0.0-1` < `1.0.0-alpha` < `1.0.0-beta` < `1.0.0` < `1.0.1` < `1.1.0`

#### `version-date`

Accepts version strings that can be parsed to a date following the ISO-8601 format `YYYY-MM-DD`. Disambiguation identifiers are allowed in the form of dot-separated-, positive-, integer-numbers with no leading zeroes.

The regex pattern for this versioning scheme is: `\d{4}-\d{2}-\d{2}(\.(0|[1-9]\d*))*`.

_Sorting behavior_: Strings are sorted first by their date part, then by numeric comparison of their disambiguation identifiers. Disambiguation identifiers follow the rules of the relaxed (version) scheme.

Examples:
`2020-01-01` < `2020-01-01.1` < `2020-02-01.1.2` < `2020-02-01.1.3` < `2020-02-01`

#### `version-string`
For packages using version strings that do not fit any of the other schemes, it accepts most arbitrary strings, but some special characters like `#` are disallowed.

_Sorting behavior_: No sorting is attempted on the version string itself. However, if the strings match exactly, the port versions can be compared and sorted.

Examples: 
`apple` <> `orange` <> `orange.2` <> `orange2`  
`watermelon` (`port-version`: 0) < `watermelon` (`port-version`: 1)

##### Example: Manifests using different versioning schemes
```json
{
    "name": "openssl",
    "version": "1.1.1",
    "port-version": 0
}
```
```json
{
    "name": "bzip2",
    "version-semver": "1.0.8",
}
```
```json
{
    "name": "abseil",
    "version-date": "2020-03-03",
    "port-version": 8
}
```
```json
{
    "name": "d3dx12",
    "version-string": "may2020",
    "port-version": 0
}
```

## 3 Specifying dependency versions

### 3.1 On manifest files
Manifest files help users specify complex versioned dependency graphs in a declarative manner. In this document we define a top-level manifest as the manifest file written by a user to declare their project’s dependencies. This is opposed to a port’s manifest file, which is used by port’s to declare the dependencies of the package it contains.

There are three mechanisms you can use in your manifest files to control which versions of your packages are installed: **version constraints, registry baselines and overrides**.

#### Version constraints
Specifying a version constraint is the most direct way to control which version of a package is installed, in vcpkg you can declare minimum version constraints using the syntax `"version>=": "1.0.0"`.

#### Registry baseline
Baselines are used to set lower boundaries on package versions. A baseline effectively adds a minimum version constraint on all the packages declared in it.

But what is a baseline?

In the main registry, the baseline is a file located in `${VCPKG_ROOT}/versions/baseline.json`. This file contains a version declaration for each package in vcpkg. The format of this file is the following:

```json
{
    "default": [
      {
        ...
        "fmt": { "version-semver": "7.1.2", "port-version": 0},
        ...
      }
    ]
}
```

The baseline file is tracked under source control. For any given revision of the registry, the versions declared in the baseline file must match the current versions of the ports in the registry at that revision.

Old revisions of vcpkg that do not contain a baseline file can still work with versioning. As a fallback, if no baseline is available at a given revision, vcpkg will use its local baseline file. If a local baseline file does not exist, the local version of the port will be used as the baseline version.

Baselines define a minimum version constraint an all packages contained in it.

For example, if the baseline contains the entry:
```
“fmt”: { “version-semver”: “7.1.2”, “port-version”: 0 }
```

A minimum version constraint will be added to `fmt` so that vcpkg won’t install a version lower than `7.1.2` with port version `0`.

#### Overrides
Declaring an override forces vcpkg to ignore all other constraints, both top-level and transitive constraints, and use the version specified in the override. This is useful for pinning exact versions and for resolving version conflicts.

## 4 Version constraints

### 4.1 Declaring a baseline
For the initial implementation, the method to declare a baseline is to set the `“$x-default-baseline”` property.

The use of `“$x-default-baseline”` is temporary and will very likely change in the future, as we work on implementing custom registries. 

#### `$x-default-baseline`
Accepts a Git commit ID. Vcpkg will try to find a baseline file in the given commit ID and use that to set the baseline versions (lower bound versions) of all declared dependencies.

When resolving version constraints for a package, vcpkg will look for a baseline version:
* First by looking at the baseline file in the given commit ID.
* If the given commit ID does not contain a baseline file, vcpkg will fallback to use the local baseline file instead.
* If there’s no local baseline file, vcpkg will use the version currently available in the ports directory.

_NOTE: If a baseline file is found, but it does not contain an entry for the package, the vcpkg invocation will fail._

Example:
```json
{
  "name": "project", 
  "version": "1.0.0",
  "dependencies": ["zlib", "fmt"],
  "$x-default-baseline":"9fd3bd594f41afb8747e20f6ac9619f26f333cbe"
}
```

Baselines can be used without any other version constraints to obtain behavior close to using “classic” mode. 

### 4.2 Declaring minimum version constraints
A minimum version requirement puts a lower boundary on the versions that can be used to satisfy a dependency. This means that any version that is newer than the requirement is valid (including major version changes).

Vcpkg will use the oldest identified version that can satisfy all the version requirements in a build graph. Using a minimum version approach has the following advantages:
* Is predictable and easy to understand.
* User controls when upgrades happen, as in, no upgrades are performed automatically when a new version is released.
* Avoids using a SAT solver.

Minimum version requirements are expressed by using the `"version>="` property in the dependencies list.

Example:
```json
{
  "name": "project",
  "version-semver": "1.0.0",
  "dependencies": [
    { "name": "zlib", "version>=": "1.2" },
    { "name": "rapidjson", "version>=": "2020-02-01" }
  ]
}
```

### 4.3 Declaring port version constraints
To be consistent with the minimum version approach, vcpkg uses the lowest available port version that matches the package version. There are many scenarios where a higher port version is desirable, e.g.: support for new platforms, fixing installation issues, among others.

As part of the dependency object a port version can be specified. An error will be emitted if a non-existent port-version for the given package version is requested.

Example:
```json
{
  "name": "project",
  "version-semver": "1.0.0",
  "dependencies": [
    { "name": "zlib", "version>=": "1.2" },
    { "name": "rapidjson", "version=": "2020-02-01", "port-version": 2 }
  ]
}
```

### 4.4 Declaring overrides
Overrides are declared as an array of package version declarations.

For an override to take effect, the overridden package must form part of the dependency graph. That means that a dependency must be declared either by the top-level manifest or be part of a transitive dependency.

Example:
```json
{
  "name": "project", 
  "version": "1.0.0",
  "dependencies": ["cpprestsdk"],
  "overrides": [{"name":"zlib", "version-semver":"1.2.10"}],
  "$x-default-baseline":"9fd3bd594f41afb8747e20f6ac9619f26f333cbe"
}
```

In the previous example, `zlib` is not a direct dependency of the project but it is a dependency for `cpprestsdk`, so the override takes effect forcing `zlib` to version `1.2.10`.

## 5 Design considerations

### 5.1 Constraint resolution
Given a manifest with a set of versioned dependencies, vcpkg will attempt to calculate a package installation plan that satisfies all the constraints. Constraints can be declared in the top-level manifest but can also be added transitively by indirect dependencies. 

Vcpkg roughly follows the steps below to compute an installation plan, the installation plan will either contain a valid set of package versions, or a list of version conflicts.

* Add all top-level constraints to the plan.
* Recursively add transitive constraints to the plan.
* Each time a constraint is added for a package, also add it’s baseline version as a minimum constraint.
* Each time a constraint is added:
  * If an override exists for the package, select the version in the override.
  * Otherwise:
    * If there is no previous version selected. 
      * Select the minimal version that satisfies the constraint.
    * If there is a previous version selected:
      * If the versioning scheme of the new constraint does not match that of the previously selected version:
        * Add a version conflict.
      * If the constraint’s version is not comparable to the previously selected version. For example, comparing “version-string: apple” to “version-string: orange”:
        * Add a version conflict.
    * If the constraints version is higher than the previously selected version:
      * Select the highest version.
      * Otherwise, keep the previous selection.
*	Review the plan:
  * If there are no conflicts, install the selected packages.
  * Otherwise, report the conflicts to the user.

### 5.2 Acquiring port versions
Although the concept of package versions has always been present in vcpkg, the concept of version constraints has been not. 

With the introduction of versioning constraints, it is now possible that a package depends on a port version that does not match the one available locally.  This raises a problem as vcpkg needs to know how to acquire the port files for the requested version.

To solve this problem, a new set of metadata needs to be introduced. This specification proposes a that a new "versions" folder is added as part of a registry. In the main vcpkg registry, this means a new root level versions directory. 

The versions directory, from here on referred as the versions database, will contain JSON files for each one of the ports available in the registry. Each file will list all the versions available for a package and contain a Git tree-ish object that vcpkg can check out to obtain that version’s portfiles. 

As part of the versioning implementation, a generator for these database files will be implemented. The generator will extract from our repository’s Git history, all the versions of each port that had been available at any moment in time and compile them into these database files. 

Example: generated `zlib.json`
```json
{
  "versions": [
    {
      "git-tree": "2dfc991c739ab9f2605c2ad91a58a7982eb15687",
      "version-string": "1.2.11",
      "port-version": 9
    },
    { “$truncated for brevity” },
    {
      "git-tree": "a516e5ee220c8250f21821077d0e3dd517f02631",
      "version-string": "1.2.10",
      "port-version": 0
    },
    {
      "git-tree": "3309ec82cd96d752ff890c441cb20ef49b52bf94",
      "version-string": "1.2.8",
      "port-version": 0
    }
  ]
}
```

For each port, its corresponding versions file should be located in  `versions/{first letter of port name}-/{port name}.json`. For example, zlib’s version file will be located in `versions/z-/zlib.json`.
Aside from port version files, the current baseline file is located in `versions/baseline.json`. 
