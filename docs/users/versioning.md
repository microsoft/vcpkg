# Versioning

**This feature is experimental and requires `--feature-flags=versions`**

Versioning allows you to deterministically control the precise revisions of dependencies used by
your project from within your manifest file.

See our guide to [getting started with versioning](versioning.getting-started.md).

## Version schemes

### Schemes
Versions in vcpkg come in four primary flavors:

#### version
A dot-separated sequence of numbers (1.2.3.4)

#### version-date
A date (2021-01-01.5)

#### version-semver
A Semantic Version 2.0 (2.1.0-rc2)

See https://semver.org/ for a full specification.

#### version-string
An exact, incomparable version (Vista)

### Port Versions
Each version additionally has a "port-version" which is a nonnegative integer. When rendered as text, the
port version (if nonzero) is added as a suffix to the primary version text separated by a hash (#).
Port-versions are sorted lexographically after the primary version text, for example:

    1.0.0 < 1.0.0#1 < 1.0.1 < 1.0.1#5 < 2.0.0

## Constraints

Manifests can place three kinds of constraints upon the versions used:

### builtin-baseline
The baseline references a commit within the vcpkg repository that
establishes a minimum version on every dependency in the graph. If
no other constraints are specified (directly or transitively),
then the version from the baseline of the top level manifest will
be used.

You can get the current commit of your vcpkg instance either by adding an empty `"builtin-baseline"` field, installing, and examining the error message or by running `git rev-parse HEAD` in the root of the vcpkg instance.

Baselines provide stability and ease of development for top-level manifest files. They are not considered from ports consumed as a dependency. If a minimum version constraint is required during transitive version resolution, the port should use `version>=`.

### version>=
Within the "dependencies" field, each dependency can have a
minimum constraint listed. These minimum constraints will be used
when transitively depending upon this library. A minimum
port-version can additionally be specified with a '#' suffix.

This constraint must refer to an existing, valid version (including port-version).

### overrides
When used as the top-level manifest (such as when running `vcpkg
install` in the directory), overrides allow a manifest to
short-circuit dependency resolution and specify exactly the
version to use. These can be used to handle version conflicts,
such as with `version-string` dependencies.

Overrides are not considered from ports consumed as a dependency.

## Example top-level manifest:
```json
{
    "name": "example",
    "version": "1.0",
    "builtin-baseline": "a14a6bcb27287e3ec138dba1b948a0cdbc337a3a",
    "dependencies": [
        { "name": "zlib", "version>=": "1.2.11#8" },
        "rapidjson"
    ],
    "overrides": [
        { "name": "rapidjson", "version": "2020-09-14" }
    ]
}
```
See also the [manifest documentation](manifests.md) for more syntax information.

## Original Specification

See also the [original specification](https://github.com/vicroms/vcpkg/blob/versioning-spec/docs/specifications/versioning.md)
