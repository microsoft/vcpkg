# Versioning Specification 

## Glossary
Some of the terms used in this document have similar meaning when discussed by the community, and because of that, they can cause confusion and ambiguity. To solve this issue, we will assign specific meaning to these terms and try to keep a consistent usage through the document.

**Library**: A piece of software (source code, binary files, documentation, license, etc.) that is intended to be reused by other software.

**Package**: A package can contain a library, collection of libraries, build scripts, software tools, or other components necessary for their use. The goal of vcpkg is to facilitate the installation of these packages in the user's environment.

**Port**: A vcpkg specific term, a port contains:

* Metadata about a package: package version, supported features, dependencies, etc.
* Instructions to acquire, build if necessary, and install the package.

## 1 Enabling package versioning
The versioning feature is disabled by default, a user can opt-in to this feature by using the `versions` feature flag, see our [documentation to learn more about feature flags](). Since versions will initially only support manifest mode, using the `versions` feature flag implies enabling `manifest`.

Example of how to enable versions:
```
vcpkg --feature-flags=versions install
```

If the versions flag is disabled, using any of the following properties in a JSON manifest will cause vcpkg to fail and warn about needing the `versions` feature flag: `version`, `version-semver`, `version-date`, `version>=`, `version=`, and `overrides`. This is compatible with existing behavior where `version-string` is the accepted versioning property.

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
Initially, package versioning will only be available in manifest mode described in:  
https://github.com/microsoft/vcpkg/blob/master/docs/users/manifests.md  

Package versioning information is divided in two parts: a version string and a port version.  
To support versioning new JSON properties need to be added to the manifest: 

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
| `version`        | For dot-separated versions      |
| `version-semver` | For SemVer compliant versions |
| `version-date`   | For dates                     |
| `version-string` | For arbitrary strings         |

A manifest must contain only one version declaration.

**`version`**  
Accepts version strings that follow a relaxed, dotted scheme. For example: OpenSSL uses version number `1.1.1` as the base for its latest LTS series and appends a single letter to indicate an update (`1.1.1a`, `1.1.1b`, `1.1.1h`). The version is logically composed of dot-separated sections (`.`), each with a numeric primary and a lowercase, alphanumeric suffix.

_Sorting behavior_: Each section's numeric primary is first compared, with a missing primary considered less than a present primary. If the numeric primary compares equal, then the alphanumeric suffix is compared byte-wise.

E.g.: 
`four` < `three` < `0` < `0.chicago` < `1.2` < `1.2.3` < `1.2.3a1` < `1.2.3aa` < `1.2.10` < `2`. 

**`version-semver`**  
Accepts version strings that follow semantic versioning conventions. 

_Sorting behavior_: Strings are sorted following the rules described in the [semantic versioning specification](https://semver.org).

E.g.:
`1.0.0-alpha` < `1.0.0-beta` < `1.0.0` < `1.0.1` < `1.1.0`.

**`version-date`**  
Accepts version strings that can be parsed to a date following the ISO-8601 format `"YYYY-MM-DD"`. A disambiguator is allowed by adding a dot (`.`) followed by the positive, nonzero disambiguation integer. E.g.: `2020-01-01.10042`, `2020-01-01.30041`.

_Sorting behavior_: Strings are sorted first by their date part, then by the disambiguator integer.

`2020-01-01` < `2020-01-02` < `2020-02-01.1` < `2020-02-01.4` < `2020-02-01`


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

* Exact version requirement (`"version=": "1.0.0"`)
* Minimum version requirement (`"version>=": "1.0.0"`)

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

### 4.1 Baseline requirements
When a package declares a dependency but omits any kind of version constraints on said dependency, vcpkg assumes this to be a “baseline requirement”.  When a baseline requirement is found, vcpkg will fill in the missing versions constraints using a specific baseline, either declared by the user or defaulted to the latest revision of the registry containing the package. 

As described in the registries specification, registries must contain a “baseline.json” file. The contents of which are used to determine what package versions are considered baseline for any specific revision of the registry. 


Before version resolution occurs, vcpkg will look for a baseline version following these steps: 

1. Checkout the registry’s “baseline.json” at the baseline commit. 
2. Find the version of the port declared in the baseline. 
3. Checkout the port files. 
4. Substitute the baseline requirement: 
    * With an exact requirement, if the package uses a version-string scheme. 
    * With a minimum requirement, otherwise. 

A baseline is declared by the user as part of their configuration. Baselines are simply put specific revisions of a registry, for Git-based registries these are either commits or tags. For filesystem-based registries, the registries spec proposes the use of named baselines. 

For the initial implementation of versioning, only commit IDs on Git-based registries will be supported and they are declared as part of a registry’s configuration using the “baseline” field. 

#### 4.1.1 Example

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

## 4.2 Exact version requirements
The simplest form of versioning. Exact version requirements resolve to an exact version of a package.  
Accomplished by using the `"version="` field in the `"dependencies"` list.

#### 4.2.1 Example

```json
{
  "name": "project", 
  "version-semver": "1.0.0",
  "dependencies": [
    { "name": "zlib", "version=": "1.2.11" },
    { "name": "rapidjson", "version=": "2020-02-08.1" }
  ]
}
```

## 4.4 Minimum version requirement
A minimum version requirement puts a lower boundary on the versions that can be used to satisfy a dependency. This means that any version that is newer than the requirement is valid (including major version changes).

Vcpkg will use the oldest identified version that can satisfy all the version requirements in the build graph.

Using a minimum version approach has the following advantages:

  * Is predictable and easy to understand.
  * User controls when upgrades happen, as in, no upgrades are performed automatically when a new version is released.
  * Avoids having to solve version SAT.  
  

Minimum version requirements are expressed by using a `version>=` property in the dependencies list. It is not allowed to use `"version="` and `"version>="` on the same dependency.

Minimum version requirements can only be used on packages using the `"version"`, `"version-semver"` and `"version-date"` schemes. 

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

### 5.1 Problem: acquiring port versions
Although the concept of package versions has always been present in vcpkg, the concept of version constraints has been not. For that reason, vcpkg only cared about the version of a port that you currently have checked out on disk.  

With the introduction of versioning constraints, it is now possible that a package depends on a port version that does not match the one available on the user’s disk.  Another problem is that vcpkg has to know how to acquire the port files for the requested version. 

To solve this problem a port versions database will now be part of the main repository, the registries spec has more details on how these databases will be implemented in custom registries.  

The form of this database is a folder containing JSON files, one file for each port available, and each file will list all the versions available for a package and how to obtain them from a Git repository.  

As part of the versioning implementation, a generator for these database files will be implemented. The generator will extract from our repository’s Git history, all the versions of each port that had been available at any moment in time and compile them into these database files.  

Example of generated `zlib.json`: 

```json
{ 
  "versions": [ 
    { 
      "git-tree": "2dfc991c739ab9f2605c2ad91a58a7982eb15687", 
      "version": "1.2.11", 
      "port-version": 9 
    }, 
    { “$truncated for brevity” }, 
    { 
      "git-tree": "a516e5ee220c8250f21821077d0e3dd517f02631", 
      "version": "1.2.10", 
      "port-version": 0 
    }, 
    { 
      "git-tree": "3309ec82cd96d752ff890c441cb20ef49b52bf94", 
      "version": "1.2.8", 
      "port-version": 0 
    } 
  ] 
} 
```

Vcpkg can use the `“git-tree”` objects to acquire (checkout) old versions of ports. 

### 5.2 Problem: version conflicts

#### 5.2.1 Example of a conflict

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

#### 5.2.2 Solution: top-level overrides
When conflicting requirements exist, an explicit override must be specified in the top-level manifest file.

Version requirement overrides are expressed using the `overrides` property in the root of the manifest. The syntax for overrides is the same as declaring a version. Overrides that are not in the top-level manifest are ignored.

By separating the overrides from the dependency requirements, the user can control whether the overrides are applied during the build graph constructiong. Using the `--no-overrides` flag, disables all of the overrides in the manifest. This is useful when changing dependency requirements, to test whether overrides are no longer required, for example, in case of a dependency upgrade.

##### 5.2.2.1 Example

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
    { "name": "C", "version": "1.2" }
  ]
}
```

The override ignores all other constraints and forces the used version of `C` to be exactly `1.2` with port version `0`.

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

The algorithm constructs a build list from the dependencies following these steps:

> Construct the rough build list for M by starting from an empty list, adding M, and then appending the build list for each of M's requirements. Simplify the rough build list to produce the final build list, by keeping only the newest version of any listed module.

We start with the top-level requirements, selecting the minimal version that satisfies each requirement and adding it to the list.

* `A >= 1.0` resolves to package `A:1.0`
* `B >= 2.0` resolves to package `B:2.0`. 
* `C >= 3.0` resolves to package `C:3.0`. 

Resulting in the package list `[ A:1.0, B:2.0, C:3.0 ]`

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

And end up with the following package list `[ A:1.0, B:2.0, C:1.0, C:3.0, C:4.0, D:1.0, E:1.1, E:1.2 ]`

The next step is to reduce the list by taking only the greates versions of each package. A package may appear multiple times in the list if it uses non-sortable version schemes.

`[ A:1.0, B:2.0, C:4.0, D:1.0, E:1.2 ]`

After obtaining a list of package candidates, we make a validation pass through all the version requirements. This time, we check that all the version constraints can be satisfied using only the selected versions in the package list.

During this step, the following are causes of conflict:

* A package appears multiple times on the list. This happens when different version schemes or multiple versions of a non-sortable scheme are requested.
* A selected version does not match an excat version requirement. This happens when a different version constraint or a minimum version constraint impose a higher requirement on the same package.

If no conflicts are detected, vcpkg will install the selected packages. Otherwise, the conflicts are reported to the user, who now has the option of using overrides to solve said conflicts.
