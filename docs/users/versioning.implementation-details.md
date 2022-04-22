# Versioning: Implementation details

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/versioning.implementation-details.md).**

## Contents

* [Minimum versioning](#minimum-versioning)
* [Constraint resolution](#constraint-resolution)
* [Acquiring port versions](#acquiring-port-versions)


### Minimum versioning
Vcpkg uses a minimal selection approach to versioning, inspired by the one [used by Go](https://research.swtch.com/vgo-mvs). But modified in some ways:

* Always starts from a fresh install, eliminates the need for upgrade/downgrade operations.
* Allow unconstrained dependencies by introducing baselines.

The minimal selection principle, however, stays the same. Given a set of constraints, vcpkg will use the "oldest" possible versions of packages that can satisfy all the constraints.
 
Using a minimum version approach has the following advantages:
* Is predictable and easy to understand.
* User controls when upgrades happen, as in, no upgrades are performed automatically when a new version is released.
* Avoids using a SAT solver.

To give an example, consider the following package graph:
```
    (A 1.0) -> (B 1.0)
    
    (A 1.1) -> (B 1.0) 
            -> (C 3.0) 
    
    (A 1.2) -> (B 2.0)
            -> (C 3.0)

    (C 2.0)
```

And the following manifest:
```
{
    "name": "example",
    "version": "1.0.0",
    "dependencies": [ 
        { "name": "A", "version>=": "1.1" },
        { "name": "C", "version>=": "2.0" }
    ], 
    "builtin-baseline": "<some git commit with A's baseline at 1.0>"
}
```

After accounting for transitive dependencies we have the following set of constraints:
* A >= 1.1
    * B >= 1.0
    * C >= 3.0
* C >= 2.0

Since vcpkg has to satisfy all the constraints, the set of installed packages becomes:

* `A 1.1`, even when `A 1.2` exists, there are no constraints higher than `1.1` so vcpkg selects the minimum version possible.
* `B 1.0`, transitively required by `A 1.1`.
* `C 3.0`, upgraded by the transitive constraint added by `B 1.0` in order to satisfy version constraints.

## Constraint resolution
Given a manifest with a set of versioned dependencies, vcpkg will attempt to calculate a package installation plan that satisfies all the constraints. 

Version constraints come in the following flavors:
* **Declared constraints**: Constraints declared explicitly in the top-level manifest using `version>=`.
* **Baseline constraints**: Constraints added implicitly by the `builtin-baseline`.
* **Transitive constraints**: Constraints added indirectly by dependencies of your dependencies.
* **Overridden constraints**: Constraints overridden in the top-level manifest using `overrides` declarations.

To compute an installation plan, vcpkg follows roughly these steps:

* Add all top-level constraints to the plan.
* Recursively add transitive constraints to the plan.
    * Each time a new package is added to the plan, also add its baseline constraint to the plan.
    * Each time a constraint is added:
    * If an override exists for the package
        * Select the version in the override.
    * Otherwise:
        * If there is no previous version selected. 
            * Select the minimal version that satisfies the constraint.
        * If there is a previous version selected:
            * If the versioning scheme of the new constraint does not match that of the previously selected version:
                * Add a version conflict.
            * If the constraint's version is not comparable to the previously selected version. For example, comparing "version-string: apple" to "version-string: orange":
                * Add a version conflict.
            * If the constraints version is higher than the previously selected version:
                * Select the highest version.
            * Otherwise: 
                * Keep the previous selection.
* Review the plan:
  * If there are no conflicts
    * Install the selected packages
  * Otherwise:
    * Report the conflicts to the user

## Acquiring port versions
Although the concept of package versions has always been present in vcpkg, the concept of version constraints has been not.

With the introduction of versioning constraints, it is now possible that a package depends on a port version that does not match the one available locally. This raises a problem as vcpkg needs to know how to acquire the port files for the requested version.

To solve this problem, a new set of metadata files was introduced. These files are located in the `versions/` directory at the root level of the vcpkg repository.

The `versions/` directory, will contain JSON files for each one of the ports available in the registry. Each file will list all the versions available for a package and contain a Git tree-ish object that vcpkg can check out to obtain that version's portfiles.

Example: `zlib.json`

```
{
  "versions": [
    {
      "git-tree": "2dfc991c739ab9f2605c2ad91a58a7982eb15687",
      "version-string": "1.2.11",
      "port-version": 9
    },
    ...
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

For each port, its corresponding versions file should be located in `versions/{first letter of port name}-/{port name}.json`. For example, zlib's version file will be located in `versions/z-/zlib.json`. Aside from port version files, the current baseline file is located in `versions/baseline.json`.


