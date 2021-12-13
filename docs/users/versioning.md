# Versioning

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/versioning.md).**

Versioning allows you to deterministically control the precise revisions of dependencies used by
your project from within your manifest file.

See our guide to [getting started with versioning](../examples/versioning.getting-started.md).

## Contents

* [Version schemes](#version-schemes)
  * [`version`](#version)
  * [`version-semver`](#version-semver)
  * [`version-date`](#version-date)
  * [`version-string`](#version-string)
* [Version constraints](#version-constraints)
* [Version files](#version-files)

## Version schemes
Ports in vcpkg should attempt to follow the versioning conventions used by the package's authors. For that reason, when declaring a package's version the appropriate scheme should be used.

Each versioning scheme defines its own rules on what is a valid version string and more importantly the rules for how to sort versions using the same scheme.

The versioning schemes understood by vcpkg are:

Manifest property | Versioning scheme
------------------|------------------------------------
`version`         | For dot-separated numeric versions
`version-semver`  | For SemVer compliant versions
`version-date`    | For dates in the format YYYY-MM-DD
`version-string`  | For arbitrary strings

A manifest must contain only one version declaration. 

_NOTE: By design, vcpkg does not compare versions that use different schemes. For example, a package
that has a `version-string: 7.1.3` cannot be compared with the same package using `version: 7.1.4`, even if the
conversion seems obvious._

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

This is the recommended versioning scheme for "Live at HEAD" libraries that don't have established release versions.

The regex pattern for this versioning scheme is: `\d{4}-\d{2}-\d{2}(\.(0|[1-9]\d*))*`

_Sorting behavior_: Strings are sorted first by their date part, then by numeric comparison of their disambiguation identifiers. Disambiguation identifiers follow the rules of the relaxed (`version`) scheme.

Examples:
`2021-01-01` < `2021-01-01.1` < `2021-02-01.1.2` < `2021-02-01.1.3` < `2021-02-01`

#### `version-string`
For packages using version strings that do not fit any of the other schemes, it accepts most arbitrary strings.  The `#` which is used to denote port versions is disallowed.

_Sorting behavior_: No sorting is attempted on the version string itself. However, if the strings match exactly, their port versions can be compared and sorted.

Examples:
* `apple` <> `orange` <> `orange.2` <> `orange2`
* `watermelon#0`< `watermelon#1`

#### `port-version`
A positive integer value that increases each time a vcpkg-specific change is made to the port.

The rules for port versions are:
* Start at 0 for the original version of the port,
* increase by 1 each time a vcpkg-specific change is made to the port that does not increase the version of the package,
* and reset to 0 each time the version of the package is updated.

_NOTE: Whenever vcpkg output a version it follows the format `<version>#<port version>`. For example `1.2.0#2` means version `1.2.0` port version `2`. When the port version is `0` the `#0` suffix is omitted (`1.2.0` implies version `1.2.0` port version `0`)._

_Sorting behavior_: If two versions compare equally, their port versions are compared by their numeric value, lower port versions take precedence.

Examples:
* `1.2.0` < `1.2.0#1` < `1.2.0#2` < `1.2.0#10`
* `2021-01-01#20` < `2021-01-01.1`
* `windows#7` < `windows#8`

## Version constraints

### `builtin-baseline`
Accepts a Git commit ID. vcpkg will try to find a baseline file in the given
commit ID and use that to set the baseline versions (lower bounds) of all
dependencies.

Baselines provide stability and ease of development for top-level manifest
files. They are not considered from ports consumed as a dependency. If a minimum
version constraint is required during transitive version resolution, the port
should use `version>=`.

Example:
```json
{
  "name": "project",
  "version": "1.0.0",
  "dependencies": ["zlib", "fmt"],
  "builtin-baseline":"9fd3bd594f41afb8747e20f6ac9619f26f333cbe"
}
```

You can get the current commit of your vcpkg instance either by adding an empty
`"builtin-baseline"` field, installing, and examining the error message or by
running `git rev-parse HEAD` in the root of the vcpkg instance.

When resolving version constraints for a package, vcpkg will look for a baseline
version by looking at the baseline file in the given commit ID. If the given
commit ID doesn't have a `versions/baseline.json` file or if the baseline file
exists but it does not declare a baseline version for the package the invocation
will fail.

This field is a convenience field that has the same semantic as replacing your
default registry in
[`vcpkg-configuration.json`](registries.md#configuration-default-registry).
```json
{
  "default-registry": {
    "kind": "builtin",
    "baseline": "<baseline>"
  }
}
```

### `version>=`
Expresses a minimum version requirement, `version>=` declarations put a lower boundary on the versions that can be used to satisfy a dependency.

**Note: Vcpkg selects the lowest version that matches all constraints, so a less-than constraint is not required.**

Example:
```json
{
  "name": "project",
  "version-semver": "1.0.0",
  "dependencies": [
    { "name": "zlib", "version>=": "1.2.11#9" },
    { "name": "fmt", "version>=": "7.1.3#1" }
  ],
  "builtin-baseline":"3426db05b996481ca31e95fff3734cf23e0f51bc"
}
```

As part of a version constraint declaration, a port version can be specified by adding the suffix `#<port-version>`, in the previous example `1.2.11#9` refers to version `1.2.11` port version `9`.

### `overrides`
Declaring an override forces vcpkg to ignore all other version constraints and use the version specified in the override. This is useful for pinning exact versions and for resolving version conflicts.

Overrides are declared as an array of package version declarations.

For an override to take effect, the overridden package must form part of the dependency graph. That means that a dependency must be declared either by the top-level manifest or be part of a transitive dependency.

```json
{
  "name": "project",
  "version-semver": "1.0.0",
  "dependencies": [
    { "name": "zlib", "version>=": "1.2.11#9" },
    "fmt"
  ],
  "builtin-baseline":"3426db05b996481ca31e95fff3734cf23e0f51bc",
  "overrides": [
    { "name": "fmt", "version": "6.0.0" }
  ]
}
```

## See Also

* The [implementation details](versioning.implementation-details.md)
* The [original specification](../specifications/versioning.md)

