# Versioning Specification 

## 1 Glossary
Some of the terms used in this document have similar meaning when discussed by the community, and because of that, they can cause confusion and ambiguity. To solve this issue, we will assign specific meaning to these terms and try to keep a consistent usage through the document.

**Library**: A piece of software (source code, binary files, documentation, license, etc.) that is intended to be reused by other software.

**Package**: A package can contain a library, collection of libraries, build scripts, software tools, or other components necessary for their use. The goal of vcpkg is to facilitate the installation of these packages in the user's environment.

**Port**: A vcpkg specific term, a port contains:

* Metadata about a package: package version, supported features, dependencies, etc.
* Instructions to acquire, build if necessary, and install the package.

## 2 Specifying package versions
Through the years, C++ software authors have adopted multiple versioning schemes and practices that sometimes conflict between each other. On vcpkg, the most recurrent versioning schemes found are:

* [Semantic Versioning](https://semver.org/)
* Date
* Repository commit
* Arbitrary string

For vcpkg to achieve wide adoption and compatibility with existing projects, it is important that we respect the versioning schemes used by each of the packages contained in our ports registry.

Currently, package versions are defined in the Version field of a port's `CONTROL` file. Moving on, we plan to phase out `CONTROL` files in favor of manifest files.

This document describes:

* How to define a package's version, versioning scheme and port revision.
* How to define version requirements for a package's dependencies.
* How vcpkg resolves version requirements.

### 2.1 Manifest files
Package versioning information can be divided in three sections: an epoch, a version string and a port version. Epochs and port versions are vcpkg specific fields, and can be specified using the following fields:

**`epoch`**  
A decimal value. Description goes here. Defaults to `0.0` if omitted.

**`port-version`**  
An integer value that increases each time a vcpkg-specific change is made to the port. 

The rules for port versions are:
* Start at 0 for the original version of the port,  
* increase by 1 each time a vcpkg-specific change is made to the port that does not increase the version of the package, 
* and reset to 0 each time the version of the package is updated.

Defaults to `0` if omitted.

### 2.1.1 Version strings

Version strings are part of the upstream metadata and should follow the scheme used by the package contained in the port. 

To declare the package version insde a manifest, a specific field must be used depending on the package's versioning scheme:

| Field            | Version scheme                |
|------------------|-------------------------------|
| `version`        | For SemVer-like versions      |
| `version-semver` | For SemVer compliant versions |
| `version-date`   | For dates                     |
| `version-string` | For arbitrary strings         |

A manifest must contain only one version declaration. If a package changes from using one versioning scheme to another, the change must be reflected by changing the `epoch` value.

**`version`**  
Accepts version strings that follow a relaxed semver-like scheme. For example: OpenSSL uses version number `1.1.1` as the base for its latest LTS series and appends a single letter to indicate an update (`1.1.1a`, `1.1.1b`, `1.1.1h`).

_Sorting behavior_: Strings are compared section by section and sorted lexicographically.  

E.g.: 
`0` < `1.2` < `1.2.3` < `1.2.4` < `1.2.4a` < `2` < `four` < `three`. 

**`version-semver`**  
Accepts version strings that follow semantic versioning conventions. 

_Sorting behavior_: Strings are sorted following the rules described in the [semantic versioning specification](https://semver.org).

E.g.:
`1.0.0-alpha` < `1.0.0-beta` < `1.0.0` < `1.0.1` < `1.1.0`.

**`version-date`**  
Accepts version strings that can be parsed to a date following the ISO-8601 format `"YYYY-MM-DD"`. A disambiguator is allowed by adding a dot (`.`) followed by the disambiguation tag. E.g.: `2020-01-01.morning`, `2020-01-01.evening`.

_Sorting behavior_: Strings are sorted only by their date part, disambiguator tags are ignored.

`2020-01-01` < `2020-01-02` < `2020-02-01`

(Disambiguators are only considered for exact version matching and are disallowed for minimum version matching).

**`version-string`**  
Accepts an arbitrary string as the versioning string. 

E.g.: `a`, `12abc45`

  _Sorting behavior_: No sorting is attempted on the versioning string itself. Sorting by `epoch` or `port-version` is stil possible.

### 2.1.1 Manifest file example

```json
{
    "name": "openssl",
    "epoch": 0.0,
    "version": "1.1.1h",
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

### 3.1 Manifest files
Manifest files help users specify complex versioned dependency graphs in a declarative manner. 

In this document we make a distinction between a top-level manifest and the manifest files used for package declarations. The top-level manifest file, simply referes to the highest manifest in the hierarchy.

There are two mechanisms to control which versions of your packages are installed: version requirements and registry baselines.

#### Version Requirements
Specifying a version requirement is the most direct way to control which version of a package is installed, in vcpkg two types of version requirements are available:

* Exact version requirement (`"version": "= 1.0.0"`)
* Minimum version requirement (`"version": ">= 1.0.0"`)

Both are explained in more detail in the [Version Requirements](#5-version-requirements) section.

#### Registry baselines
A baseline is the mechanism used to set the version of packages that do not have any version requirement imposed on them, either directly in the top-level manifest or transitively by another package in the build graph. 

Simply put, a baseline is a commit ID to a specific revision of a registry. Vcpkg uses the baseline to fill in the versions of packages that don't have any requirements set.

Setting a baseline is optional, when a baseline is not explicitly set, vcpkg uses the latest revision of the registry.

```json
{
    "registries": [
      {
        "kind": "git",
        "repository": "https://github.com/my-org/vcpkg-ports",
        "baseline": "my-project-baseline",
        "scopes": [ "myorg" ]
      }
    ]
}
```

## 4 Version requirements

### 4.1 Semver version matching
When using semantic versioning is sometimes convenient to shorten the version string when the least significative parts are not relevant. For example, when talking about a package where only the MAJOR and MINOR versions are important, it is convenient to say `2.2` instead of `2.2.0`, `2.2.1`, `2.2.1`, and so on.

In vcpkg, when resolving version requirements, the specificity of the version string is important.

Truncated parts of a SemVer string are considered as if they were filled with zeroes, e.g.:

* `2` is interpreted as `2.0.0`
* `2.1` is interpreted as `2.1.0`.

### 4.2 Baseline requirements
When a dependency declaration lacks any version requirement vcpkg will use the package registry's baseline to fill in the missing information. 

Before version resolution ocurrs, vcpkg will look for the current version of each package in the baseline and treat packages with no requirements as if they had declared a minimum version on it. 

If the baseline versioning scheme does not support minimum version requirements, vcpkg will instead add an exact version requirement.

#### 4.2.1 Example

`project/vcpkg-config.json`
```json
{
    "registries": [
      {
        "kind": "builtin",
        "baseline": "acd2f59e931172f46706ef8ac2fc9b21f71fba85",
      }
    ]
}
```

`project/vcpkg.json`
```json
{
    "name": "project",
    "version-semver": "1.0.0", 
    "dependencies": [ "zlib", {"name": "rapidjson", "version=": "2020-02-08"}]
}
```

In the above example, vcpkg will find the version of `zlib` that exists in baseline commit `acd2f59` to be `1.2.11`.
During the version resolution step, vcpkg will treat `zlib` as if it had a minimum version requirement on `1.2.11`.

## 4.3 Exact version requirements
The simplest form of versioning. Exact version requirements resolve to an exact version of a package.  
Accomplished by using the `"version="` field in the `"dependencies"` list.

#### 4.3.1 Example

```json
{
  "name": "project", 
  "version-semver": "1.0.0",
  "dependencies": [
    { "name": "zlib", "version=": "1.2.11" },
    { "name": "rapidjson", "version=": "2020-02-08.nightly" }
  ]
}
```

## 4.4 Minimum version requirement
A minimum version requirement puts a lower boundary on the versions that can be used to satisfy a dependency. This means that any version that is newer than the requirement is valid (including major version changes).

Vcpkg will use the oldest version available that can satisfy all the version requirements in the build graph.

Using a minimum version approach has the following advantages:

  * Is predictable and easy to understand.
  * User controls when upgrades happen, as in, no upgrades are performed automatically when a new version is released.
  * Avoids having to solve version SAT.  
  
  _Note: Unexpected downgrades are still possible if a lower version is retro-actively released and added to the package registries. To overcome the issue, the use of Lockfiles is necessary._

Minimum version requirements are expressed by using a "version>=" property in the dependencies list. It is not allowed to use "version=" and "version>=" on the same dependency.

Minimum version requirements can only be used on packages using the `version`, `version-semver` and `version-date` schemes. 

### 4.4.1 Example

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

## 4.5 Port versions
To be consistent with the minimum version approach, vcpkg uses the lowest available port version that matches the package version. There are many scenarios where a higher port version is desirable, e.g.: support for new platforms, fixing installation issues, among others.

As part of the dependency object a `port-version` can be specified. An error will be emitted if a non-existent `port-version` for the given package version is requested. 

It is recommended to use `port-version` in combination with `version=` requirements. As `port-version` is reset to 0 each time the package version changes, using minimum requirements can result in errors with higher values. 

### 4.5.1 Port versions example
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

## 5 Design considerations

### 5.1 Problem: version conflicts

#### 5.1.1 Example of a conflict

Consider the following manifest files:

**Project manifest**
```json
{
    "name": "project",
    "version": "1.0",
    "dependencies": [
        { "name": "A", "version=": "1.0" },
        { "name": "B", "version=": "1.0" }]
}
```

**A's manifest**
```json
{
    "name": "A",
    "version": "1.0.0",
    "dependencies": [{ "name": "C", "version=": "1.1" }]
}
```

**B's manifest**
```json
{
    "name": "B",
    "version": "1.0.0",
    "dependencies": [{ "name": "C", "version=": "1.2" }]
}
```

There are conflicting requirements for `C`, as package `A` requires version `1.1`, and package `B` requires version `1.2`.

#### 5.1.2 Solution: top-level overrides
When conflicting requirements exist, an explicit override must be specified in the top-level manifest file.

Version requirement overrides are expressed using the `overrides` property in the root of the manifest. The syntax for overrides is the same as for version requirements. Overrides that are not in the top-level manifest are ignored.

By separating the overrides from the dependency requirements, the user can control whether the overrides are applied during the build graph constructiong. Using the `--no-overrides` flag, disables all of the overrides in the manifest. This is useful when changing dependency requirements, to test whether overrides are no longer required, for example, in case of a dependency upgrade.

##### 5.1.2.1 Example

The example in 5.1.1 can be solved by overriding the requirements of package `C` like this:

```json
{
  "name": "project",
  "version": "1.0",
  "dependencies": [
    { "name": "A", "version=": "1.0" },
    { "name": "B", "version=": "1.0" }
  ],
  "overrides": [
    { "name": "C", "version>=": "1.2" }
  ]
}
```

The override is equivalent to changing the version requirements for `C` on both `A`'s manifest and `B`'s manifest to:

```json
{ "name": "C", "version>=": "1.2" }
``` 

### 5.2 Problem: block major version upgrades
Under Semantic Versioning, major version changes introduce breaking changes to public API. Using minimum version requirements can result in unexpected major version upgrades of packages in the dependency list. To overcome this issue a user has two options:

* 1) Override the minimum version requirements
* 2) Use exclusion lists (described below).

### 5.2.1 Solution: exclusion lists (WIP)
Exclusion lists have the following properties:

* Accept `"version>"`, `"version>="`, and `"version="` exclusions.
* Exclusions are un-conditional. I.e.: not in the form of "If `A:1.x` then not `B:1.Y`" or similar.
* Defined in their own section in the manifest.
* Exclusions that are not in the top-level manifest are ignored.

An exclusion takes a package version out of the candidate list when resolving version requirements. Effectively, is the same as if the versions in the exclusion list did not exist.

#### 5.2.1.1 Example
Consider that the following packages with these versions exist:

* `A: [1.0, 1.1, 2.0]`
* `B: [1.0.0, 2.0.0, 2.1.0, 2.1.1, 2.2.0]`
* `C: [1.0, 1.1, 2.0, 2.1, 3.0]`
* `C:3.0 depends on A:>=2.0`

And the following manifest file

```json
{
  "name": "project",
  "dependencies": [
    { "name": "A", "version>=": "1.0" },
    { "name": "B", "version>=": "2.0" },
    { "name": "C", "version>=": "3.0" }
  ],
  "exclude": [
    { "name": "A", "version>=": "2.0" },
    { "name": "B", "version=": "2.0" },
    { "name": "B", "version=": "2.1.0" },
    { "name": "B", "version=": "2.1.1" }
  ]
}
```

Using the exlusions effectively reduces the candidate set to:

* `A: [1.0, 1.1]`
* `B: [1.0.0, 2.2.0]`
* `C: [1.0, 1.1, 2.0, 2.1, 3.0]`
* `C:3.0 depends on A:>=2.0`

Without exclusions this would resolve in:

* `A:2.0` (upgraded by `C:3.0`'s requirement).
* `B:2.0.0`
* `C:3.0`

With exclusions the outcome is:

* `A: error` (C:3.0 requires A>=2.0, which does not exist)
* `B: 2.2.0`
* `C: 3.0`

### 5.2.1.2 Wildcard character
A wildcard character `*` can be used in `version=` exclusions for convenience. 

The wildcard character `*` can only appear at the end of a version string, replacing the digits that would go into that part of the semver string.  

E.g.: 
* `2.*` and `2.0.*` are valid, 
* `2.*.1` and `2.1.1*` are invalid.

The exclusion in the previous example can be reduced to:

```json
  { "name": "B", "not": "2.1.*" }
```

## 6 Algorithm
The implementation is based on the algorithm proposed in https://research.swtch.com/vgo-mvs with some modifications to adapt it to vcpkg version requirements.

To explain the algorithm we will use the following graph to represent the dependencies of a project.

* Blue arrows represent minimum version requirements.
* Green arrows represent exact version requirements.

![example package graph image](res/example-package-graph.png)

Also consider the following manifest file for the project:

```json
{
  "name": "project",
  "version": "1.0", 
  "dependencies": [
    { "name": "A", "version>=": "1.0" },
    { "name": "B", "version>=": "2.0" },
    { "name": "C", "version>=": "3.0" }
  ]
}
```

The original algorithm constructs a build list from the dependencies following these steps:

> Construct the rough build list for M by starting from an empty list, adding M, and then appending the build list for each of M's requirements. Simplify the rough build list to produce the final build list, by keeping only the newest version of any listed module.

In vcpkg's case, keeping only the newest versions can result in the violation of exact version requirements. 

The solution is to create two build lists, one for minimum requirements and one for exact requirements. The contents of both build lists are merged and then either a valid build list is created or a conflict is reported.

To create the minimum versions list, follow the steps in the original algorithm, keeping only the greatest version of each package on the list.

To create the exact versions list, keep each version of a package that is required, if a package appears more than once in the list, report a conflict.

In our example, to construct a build list for the project we start with its direct requirements, selecting the minimal version that satisfies each requirement. 

* `A >= 1.0` resolves to package `A:1.0`
* `B >= 2.0` resolves to package `B:2.0`. 
* `C >= 3.0` resolves to package `C:3.0`. 

Resulting in: 

* Minimum versions `[ A:1.0, B:2.0, C:3.0 ]` 
* Exact versions `[]`. 

After that we recursively resolve downstream requirements for the packages added to the lists.  

From `A:1.0` (top-level requirement)

* `C >= 1.0` resolves to package `C:1.0` 

From `B:2.0` (top-level requirement)

* `C = 4.0` resolves to package `C:4.0`
* `D = 1.0` resolves to package `D:1.0`

From `C:3.0` (top-level requirement)

* `E >= 1.1` resolves to package `E:1.1` 

From `C:4.0` (added by `B:2.0`)

* `E>=1.2` resolves to package `E:1.2` 

Resulting in the following lists: 

* Minimum versions `[ A:1.0, B:2.0, C:1.0, C:3.0, E:1.1, E:1.2 ]`
* Exact versions `[ C:4.0, D:1.0 ]` 

Following the original algorithm, we take only the greatest versions of packages in the minimum versions list.

* Minimum versions  `[ A:1.0, B:2.0, C:3.0, E:1.2 ]` (after redux)
* Exact versions `[ C:4.0, D:1.0 ]`

The last step is merging both lists, for which we follow these rules: 

* If a package appears only in one list, add the version of that package to the final list. 

* If a package appears on both lists AND the exact version is greater than or equal to the minimum version, take the exact version.

* If a package appears on both lists AND the exact version is lower than the minimum version, fail the build and report the conflict. 

The result of merging both lists in the example results in the final requirement list `[A:1.0, B:2.0, C:4.0, D:1.0, E:1.2]`. 

After obtaining a valid build list, vcpkg will record the selected versions for each package in a **lockfile**. On future runs, if no changes to the version requirements have been made, vcpkg will use the versions in the lockfile to avoid running the algorithm. 
