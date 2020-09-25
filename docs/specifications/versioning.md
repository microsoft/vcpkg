# Versioning Specification 

## 1 Glossary
Some of the terms used in this document have similar meaning when discussed by the community, and because of that, they can cause confusion and ambiguity. To solve this issue, we will assign specific meaning to these terms and try to keep a consistent usage through the document.

**Library**: A piece of software (source code, binary files, documentation, license, etc.) that is intended to be reused by other software.

**Package**: A package can contain a library, collection of libraries, build scripts, software tools, or other components necessary for their use. The goal of VCPKG is to facilitate the installation of these packages in the user's environment.

**Port**: A VCPKG specific term, a port contains:

* Metadata about a package: package version, supported features, dependencies, etc.
* Instructions to acquire, build if necessary, and install the package.

## 2 Specifying package versions
Through the years, C++ software authors have adopted multiple versioning schemes and practices that sometimes conflict between each other. On VCPKG, the most recurrent versioning schemes found are:

* [Semantic Versioning](https://semver.org/)
* Date
* Repository commit
* Arbitrary string

For VCPKG to achieve wide adoption and interoperability with existing projects, it is important that we respect the versioning schemes used by each of the packages contained in our ports library.

Currently, package versions are defined in the Version field of a port's `CONTROL` file. Moving on, we plan to phase out `CONTROL` files in favor of manifest files.

This document describes:

* How to define a package's version, versioning scheme and port revision.
* How to define version requirements for a package's dependencies.
* How VCPKG resolves version requirements.

### 2.1 Manifest files
Package versioning information is specified using the following fields:

**`version-scheme`** 
The versioning scheme used by the package. VCPKG splits versions into four different kinds: `semver`, `date`, `commit`, and `string`. VCPKG uses the field to validate format constraints and determine which version matching operations are supported by the package.

* **`semver`**: Accepts version strings that follow semantic versioning conventions. Packages that use this scheme can be sorted which allows VCPKG to apply minimum version requirement constraints on them.

    _Note: some packages that follow semver-like convetions are not actually semver compliant, for examples: `openssl`, and for that reason are more suited to use the arbitrary string versioning scheme._

* **`date`**: Accepts version strings that can be parsed to a date following the ISO-8601 format `"YYYY-MM-DD"`. Packages that use this scheme can be sorted which allows VCPKG to apply minimum version requirement constraints on them.


* **`commit`**: Accepts version strings that represent commit IDs under versioning control systems. These are usually hash strings that are not sortable, and as such, VCPKG can only apply direct version requirements on them.

* **`string`**: Accepts an arbitrary string as the versioning string. The versioning string may not contain escaped characters nor any of the following characters: `@`, `:`, `` ` ``. VCPKG can only apply direct version requirements on packages using this versioning scheme.

**`version`**
The version must match the version of the package being installed. VCPKG validates that the string follows the format specified in the `version-scheme` field and reports an error if the version string is not valid.

**`port-version`**
Historically, VCPKG port version numbers were added as a suffix to the version string in `CONTROL` files. This practice must now be disallowed, and port versions should be instead specified by this field.  Port versions deal with VCPKG specific changes and do not change the version of the package being installed. 

Port version values should start at 0 for the original version, increase by 1 each time a new port version is published, and reset each time the "version" or "version-scheme" fields are changed.

When resolving package versions only the latest port version is considered, it is a responsibility of the port owner to ensure that no bugs or regressions are introduced when updating the port.

### 2.1.1 Manifest file example

```json
{
    "name": "opencv",
    "version": "4.1.1",
    "version-scheme": "semver",
    "port-revision": 5
}
```

## 3 Specifying dependency versions

### 3.1 Manifest files
A version requirement can be expressed by using the `"version"` and `"minimum-version"` fields on each dependency. Both are explained in more detail in the [Version Requirements] section.

## 4 CLI changes

### 4.1 Command: `install`
A change to the current install command is needed so users can install specific versions of a package.

The new install syntax follows the pattern:

`vcpkg install package[@version][:triplet]`

For example:

`vcpkg install package zlib@1.2.11:x64-windows`

The version in the `install` command must be an exact match of a package version.

### 4.2 Command: `search`
By default, the search command will only show the latest version of listed packages> To show previous versions of packages. the option `--show-versions` must be passed.

Example:

```
vcpkg search zlib --show-versions
zlib        1.2.11      A compression library
zlib        1.2.10      A compression library
zlib        1.2.8       A compression library
```

## 5 Version requirements

### 5.1 Semver version matching
When using semantic versioning is sometimes convenient to shorten the version string when the least significative parts are not relevant. For example, if when talking about a package only the MAJOR and MINOR versions are important, it is convenient to say `2.2` instead of `2.2.0`, `2.2.1`, `2.2.1`, and so on.

In VCPKG, when resolving version requirements, the specificity of the version string is important.

Truncated parts of a SemVer string are considered as if they were filled with zeroes, e.g.:

* `2` is interpreted as `2.0.0`
* `2.1` is interpreted as `2.1.0`.

### 5.2 No requirements
By not specifying a version requirement, the user implies that the version to install is unimportant. This results in different versions getting installed depending on the circumstances (the composition of the build graph).

Example: A project depends on package `meow` but doesn't specify a version requirement.

* If no version requirements for `meow` are added by a dependency when constructing the build list, the latest version of `meow` is installed.
* If version requirements for `meow` are added by a dependency when constructing the build list:
  * And there are no conflicts, the oldest version of `meow` that satisfies all the requirements is installed.
  * And there are conflict, the build fails and the conflicts are reported.

#### 5.2.1 Example

Project manifest
```json
{
    "name": "project",
    "version": "1.0.0", 
    "version-scheme": "semver",
    "dependencies": [ "zlib", "rapidjson" ]
}
```

## 5.3 Direct version requirements
The simplest form of versioning. Direct version requirements resolve to an exact version of a package.  
Accomplished by using the `"version"` field in the `"dependencies"` list.

#### 5.3.1 Example

```json
{
    "name": "project", 
    "version": "1.0.0",
    "version-scheme": "semver",
    "dependencies": [
        { "name": "zlib", "version": "1.2.11" },
        { "name": "rapidjson", "version": "2020-02-08", "version-scheme": "date" }]
}
```

If omitted, `"version-scheme"` defaults to "semver". In the example, `"version-scheme": "date` is required, otherwise an error would be reported as `"2020-02-08"` is not a valid semver string.

## 5.4 Minimum version requirement
A minimum version requirement puts a lower boundary on the versions that can be used to satisfy a dependency. This means that any version that is newer than the requirement is valid (including major version changes).

VCPKG will use the "oldest" version available that can satisfy all the version requirements in the build graph.

Using a minimum version approach has the following advantages:

  * Is predictable and easy to understand.
  * Avoids having to solve version SAT.
  * Avoids unnecesary upgrades when new versions are released.  
  
  _Note: Unexpected downgrades are still possible if a lower version is retro-actively released or added to the package repository. To overcome the issue, the use of Lockfiles is necessary._

Minimum version requirements are expressed by using a "minimum-version" property in the dependencies list. It is not allowed to use the "version" and "minimum-version" properties on the same dependency.

Minimum version requirements can only be used on packages using `semver` or `date` versioning schemes. 

### 5.4.1 Example

```json
{
    "name": "project",
    "version": "1.0.0",
    "dependencies": [
        { "name": "zlib", "minimum-version": "1.2" },
        { "name": "rapidjson", "minimum-version": "2020-02-01", "version-scheme": "date"}]
}
```

## 6 Design considerations

### 6.1 Problem: version conflicts

#### 6.1.1 Example of a conflict

Consider the following manifest files:

**Project manifest**
```json
{
    "name": "project",
    "version": "1.0",
    "dependencies": [
        { "name": "A", "version": "1.0" },
        { "name": "B", "version": "1.0" }]
}
```

**A's manifest**
```json
{
    "name": "A",
    "version": "1.0.0",
    "dependencies": [{ "name": "C", "version": "1.1" }]
}
```

**B's manifest**
```json
{
    "name": "B",
    "version": "1.0.0",
    "dependencies": [{ "name": "C", "version": "1.2" }]
}
```

There are conflicting requirements for `C`, as package `A` requires version `1.1`, and package `B` requires version `1.2`.

#### 6.1.2 Solution: top-level overrides
When conflicting requirements exist, an explicit override must be specified in the top-level manifest file.

Version requirement overrides are expressed using the `overrides` property in the root of the manifest. The syntax for overrides is the same as for version requirements. Overrides that are not in the top-level manifest are ignored.

By separating the overrides from the dependency requirements, the user can control whether the overrides are applied during the build graph constructiong. Using the `--no-overrides` flag, disables all of the overrides in the manifest. This is useful when changing dependency requirements, to test whether overrides are no longer required, for example, in case of a dependency upgrade.

##### 6.1.2.1 Example

The example in 6.1.1 can be solved by overriding the requirements of package `C` like this:

```json
{
    "name": "project",
    "version": "1.0",
    "dependencies": [
        { "name": "A", "version": "1.0" },
        { "name": "B", "version": "1.0" }],
    "overrides": [{ "name": "C", "minimum-version": "1.2" }]
}
```

The override is equivalent to changing the version requirements for `C` on both `A`'s manifest and `B`'s manifest to:

```json
{ "name": "C", "minimum-version": "1.2" }
``` 

### 6.2 Problem: block major version upgrades
Under Semantic Versioning, major version changes introduce breaking changes to public API. Using minimum version requirements can result in unexpected major version upgrades of packages in the dependency list. To overcome this issue a user has two options:

* 1) Override the minimum version requirements
* 2) Use exclusion lists (described below).

### 6.2.1 Solution: exclusion lists (WIP)
Exclusion lists have the following properties:

* Accept `"greater"`, `"greater-or-equal"`, and `"not"` exclusions.
* Exclusions are un-conditional. I.e.: not in the form of "If `A:1.x` then not `B:1.Y`" or similar.
* Defined in their own section in the manifest.
* Exclusions that are not in the top-level manifest are ignored.

An exclusion takes a package version out of the candidate list when resolving version requirements. Effectively, is the same as if the versions in the exclusion list did not exist.

#### 6.2.1.1 Example
Consider that the following package and their versions exist:

* `A: [1.0, 1.1, 2.0]`
* `B: [1.0.0, 2.0.0, 2.1.0, 2.1.1, 2.2.0]`
* `C: [1.0, 1.1, 2.0, 2.1, 3.0]`
* `C:3.0 depends on A:>=2.0`

And the following manifest file

```json
{
    "name": "project",
    "dependencies": [
        { "name": "A", "minimum-version": "1.0" },
        { "name": "B", "minimum-version": "2.0" },
        { "name": "C", "minimum-version": "3.0" }
    ],
    "exclude": [
        { "name": "A", "greater-or-equal": "2.0" },
        { "name": "B", "not": "2.0" },
        { "name": "B", "not": "2.1.0" },
        { "name": "B", "not": "2.1.1" }
    ]
}
```

Without exclusions this would resolve in:

* `A:2.0` (upgraded by `C:3.0`'s requirement).
* `B:2.0.0`
* `C:3.0`

With exclusions the outcome is:

* `A: error` (blocks unexpected upgrade resulting in an error)
* `B: 2.2.0`
* `C: 3.0`

### 6.2.1.2 Wildcard character
A wildcard character `*` can be used in `not` exclusions for convenience. 

The wildcard character `*` can only appear at the end of a version string, replacing the digits that would go into that part of the semver string. E.g.: the version strings `2.*` and `2.0.*` are valid, while `2.*.1` and `2.1.1*` are invalid.

The exclusion in example 6.2.1.1:

```json
        { "name": "B", "not": "2.1.0" },
        { "name": "B", "not": "2.1.1" }
```

could be merged into:

```json
        { "name": "B", "not": "2.1.*" }
```

which would exclude all versions that begin with `"2.1"`.

## 7 Algorithm
The implementation is based on the algorithm proposed in https://research.swtch.com/vgo-mvs with some modifications to adapt it to VCPKG version requirements.

To explain the algorithm we will use the following graph to represent the dependencies of a project.

* Blue arrows represent `minimum-version` requirements.
* Green arrows represent exact `version` requirements.

![example package graph image](res/example-package-graph.png)

Also consider the following manifest file for the project:

```json
{
    "name": "project",
    "version": "1.0", 
    "dependencies": [
        { "name": "A", "minimum-version": "1.0" },
        { "name": "B", "minimum-version": "2.0" },
        { "name": "C", "minimum-version": "3.0" }
    ]
}
```

The original algorithm constructs a build list from the dependencies following these steps:

> Construct the rough build list for M by starting from an empty list, adding M, and then appending the build list for each of M's requirements. Simplify the rough build list to produce the final build list, by keeping only the newest version of any listed module.

In VCPKG's case, keeping only the newest versions can result in the violation of direct version requirements. The solution is to create two build lists, one for minimum version requirements (MVR) and one for direct version requirements (DVR). The solutions from these build lists are merged and then either a valid build list is created or a conflict is reported.

To create the MVR list, follow the steps in the original algorithm, keeping only the greatest version of each package on the list.

To create the DVR list, keep each version of a package that is required, if a package appears more than once in the list, report a conflict.

In our example, to construct a build list for Project we start with its direct requirements, selecting the minimal version that satisfies each requirement. 

* `A >= 1.0` resolves to package `A:1.0`
* `B >= 2.0` resolves to package `B:2.0`. 
* `C >= 3.0` resolves to package `C:3.0`. 

Resulting in: 

* MVR list `[ A:1.0, B:2.0, C:3.0 ]` 
* DVR list `[]`. 

After that we recursively resolve downstream requirements for the packages added to the lists.  

From `A:1.0` 

* `C >= 1.0` resolves to package `C:1.0` 

From `B:2.0` 

* `C:4.0` (direct version requirement) 
* `D:1.0` (direct version requirement) 

From `C:3.0` 

* `E>=1.1` resolves to package `E:1.1` 

From `C:4.0` 

* `E>=1.2` resolves to package `E:1.2` 

Resulting in the temporary lists: 

* MRV list `[ A:1.0, B:2.0, C:1.0, C:3.0, E:1.1, E:1.2]`
* DRV list `[ C:4.0, D:1.0 ]` 

 The lists are then validated resulting in the final temporary lists: 

* MRV list `[ A:1.0, B:2.0, C:3.0, E:1.2 ]` (only latest version of each package)
* DRV list `[ C:4.0, D: 1.0 ]` (no conflicts)

The last step is merging both lists, for which we follow these rules: 

* If a package appears only in one list, add the version of that package to the final list. 

* If a package appears on both lists AND the DRL version is greater than or equal to the MRL version, take the DRL version. 
* If a package appears on both lists AND the DRL version is lower than the MRL version, fail the build and report the conflict. 

The result of merging both lists in the example results in the final requirement list `[A:1.0, B:2.0, C:4.0, D:1.0, E:1.2]`. 

After obtaining a valid build list, VCPKG will record the selected versions for each package in a **lockfile**. On future runs, if no changes to the version requirements have been made, VCPKG will use the versions in the lockfile to avoid running the algorithm. 
