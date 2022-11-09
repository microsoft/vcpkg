# Using Registries

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/registries.md).**

There are two parts to using registries; this documents the use side of the
relationship. In order to learn more about creating registries for others to
use, please read [this documentation](../maintainers/registries.md).

## Table of Contents

- [Using Registries](#using-registries)
  - [Table of Contents](#table-of-contents)
  - [`vcpkg-configuration.json`](#vcpkg-configurationjson)
    - [Registry Objects](#registry-objects)
      - [Registry Objects: `"kind"`](#registry-objects-kind)
      - [Registry Objects: `"baseline"`](#registry-objects-baseline)
      - [Registry Objects: `"repository"`](#registry-objects-repository)
      - [Registry Objects: `"path"`](#registry-objects-path)
      - [Registry Objects: `"packages"`](#registry-objects-packages)
    - [Configuration: `"default-registry"`](#configuration-default-registry)
    - [Configuration: `"registries"`](#configuration-registries)
    - [Example Configuration File](#example-configuration-file)
  - [Package Name Resolution](#package-name-resolution)
    - [Versioning Support](#versioning-support)

## `vcpkg-configuration.json`

From a high level perspective, everything that a project needs to define
about registries is contained in the vcpkg configuration file. In classic
mode, the configuration file lies in the vcpkg root; for manifest mode,
the file must exist next to the project's `vcpkg.json` file.
This file is named `vcpkg-configuration.json`, and it's a simple top-level
object file.

### Registry Objects

Registries are defined in JSON as objects. They must contain at least the
`"kind"` and `"baseline"` fields, and additionally the different kinds of
registry will have their own way of defining where the registry can be found:

- git registries require the `"repository"` field
- filesystem registries require the `"path"` field
- built-in registries do not require a field, since there is only one
  built-in registry.

#### Registry Objects: `"kind"`

The `"kind"` field must be a string:

- For git registries: `"git"`
- For filesystem registries: `"filesystem"`
- For the builtin registry: `"builtin"`

#### Registry Objects: `"baseline"`

The `"baseline"` field must be a string. It defines a minimum version for all packages coming from this registry configuration.

For [Git Registries](../maintainers/registries.md#git-registries) and for the [Builtin Registry](../maintainers/registries.md#builtin-registries), it should be a 40-character git commit sha in the registry's repository that contains a `versions/baseline.json`.

For [Filesystem Registries](../maintainers/registries.md#filesystem-registries), it can be any valid baseline string that the registry defines.

#### Registry Objects: `"repository"`

This should be a string, of any repository format that git understands:

- `"https://github.com/microsoft/vcpkg"`
- `"git@github.com:microsoft/vcpkg"`
- `"/dev/vcpkg-registry"`

#### Registry Objects: `"path"`

This should be a path; it can be either absolute or relative; relative paths
will be based at the directory the `vcpkg-configuration.json` lives in.

#### Registry Objects: `"packages"`

With exception of the default registry and artifacts registries. All registries
must declare the packages they provide using the `"packages"` array.

Each entry in the array must be:
* a package name, or
* a package prefix.

Package names may contain only lowercase letters, digits, and `-`. Package names cannot start or end with `-`.

Package prefixes must follow these rules:
* Use the wildcard character: `*` 
     * `*` matches zero or more port name characters (lowercase letters, digits, and `-`).
* Contain only one wildcard (`*`) 
* The wildcard (`*`) must be the last character in the pattern.
* All characters before the wildcard `*` must be valid port name characters.

Examples of valid patterns:
* `*`: Matches all port names
* `b*`: Matches ports that start with the letter `b`
* `boost-*`: Matches ports that start with the prefix `boost-`

Examples of invalid patterns:
* `*a` (`*` must be the last character in the prefix)
* `a**` (only one `*` is allowed)
* `a+` (`+` is not a valid wildcard)
* `a?` (`?` is not a valid wildcard)

See [package name resolution](#package-name-resolution) for more details.

### Configuration: `"default-registry"`

The `"default-registry"` field should be a registry object. It defines
the registry that is used for all packages that are not claimed by any
package registries. It may also be `null`, in which case no packages that
are not claimed by package registries may be installed.

### Configuration: `"registries"`

The `"registries"` field should be an array of registry objects, each of
which additionally contain a `"packages"` field, which should be an array of
package names. These define the package registries, which are used for 
the specific packages named by the `"packages"` field.

The `"packages"` fields of all the package registries must be disjoint.

### Example Configuration File

Let's assume that you have mirrored <https://github.com/microsoft/vcpkg> at
<https://git.example.com/vcpkg>: this will be your default registry.
Additionally, you want to use North Wind Trader's registry for their
beison and beicode libraries. The following `vcpkg-configuration.json`
will work:

```json
{
  "default-registry": {
    "kind": "git",
    "repository": "https://internal/mirror/of/github.com/Microsoft/vcpkg",
    "baseline": "eefee7408133f3a0fef711ef9c6a3677b7e06fd7"
  },
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/northwindtraders/vcpkg-registry",
      "baseline": "dacf4de488094a384ca2c202b923ccc097956e0c",
      "packages": [ "beicode", "beison" ]
    }
  ]
}
```

## Package Name Resolution

Package name resolution in vcpkg is designed to be predictable and easy to understand. Given a
`vcpkg-configuration.json` file, it should be simple to tell which registry will provide any given port name.

When resolving a port name to a registry, we prioritize as follows:
1. Exact match
2. Pattern match
    * Longer prefixes have higher priority, e.g.: when resolving `boost`, `boost*` > `b*` > `*`
3. Default registry
4. If the default registry has been set to null, emit an error

Package names have higher priority than prefixes even if they both match the same amount of characters. 
For example, when resolving `boost`: `boost` > `boost*`.

If there is a tie in priority, vcpkg will use the first registry that declares the package name or prefix. 
_This makes the order in which registries are declared in the `"registries"` array important._

### Example #1: Package name resolution

`vcpkg-configuration.json`
```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/northwindtraders/vcpkg-registry",
      "baseline": "dacf4de488094a384ca2c202b923ccc097956e0c",
      "packages": ["bei*"]
    },
    {
      "kind": "git",
      "repository": "https://github.com/vicroms/vcpkg-registry",
      "baseline": "dacf4de488094a384ca2c202b923ccc097956e0c",
      "packages": ["beicode", "bei*"]
    }
  ]
}

```

`vcpkg.json`
```json
{
  "dependencies": [ 
    "beicode", 
    "beison",
    "fmt"
  ]  
}
```

Given this configuration, each package name resolves to:

* `beicode`: from registry `https://github.com/vicroms/vcpkg-registry` (exact match on `beicode`)
* `beison`: from registry `https://github.com/northwindtraders/vcpkg-registry` (pattern match on `beison` and declared first in `"registries"` array)
* `fmt`: from default registry (no matches)

Because multiple registries declare `bei*`, vcpkg will also emit the following warning:

```no-highlight
Found the following problems in configuration (path/to/vcpkg-configuration.json):
$ (a configuration object): warning: Package "bei*" is duplicated.
    First declared in:
        location: $.registries[0].packages[0]
        registry: https://github.com/northwindtraders/vcpkg-registry

    The following redeclarations will be ignored:
        location: $.registries[1].packages[1]
        registry: https://github.com/vicroms/vcpkg-registry
```

### Example #2: Overriding the default registry

There are two ways for a user to override the default registry. 

One way is to use the `"default-registry"` object:
```json
{
  "default-registry": {
    "kind": "git",
    "repository": "https://github.com/Microsoft/vcpkg",
    "baseline": "e79c0d2b5d72eb3063cf32a1f7de1a9cf19930f3"
  }
}
```

The other way is to use the `"*"` pattern in the first registry of the `"registries"` array.
```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/Microsoft/vcpkg",
      "baseline": "e79c0d2b5d72eb3063cf32a1f7de1a9cf19930f3",
      "packages": ["*"]
    }
  ]
}
```

An advantage of the second form is that you can add more entries to the packages array, while the
`"default-registry"` object doesn't allow you to define a packages array at all. This difference
becomes important in cases where you need to ensure that a package comes from the default registry, like
in the example below.

### Example #3: Ensuring correct name resolution

Let's consider a registry that provides the Qt Framework libraries.

`vcpkg-configuration.json`
```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/custom-qt/custom-qt-registry",
      "baseline": "adfc4de488094a384ca2c202b923ccc097956e0c",
      "packages": ["qt*"]
    }
  ]
}
```

And the following project dependencies:

`vcpkg.json`
```json
{
  "dependencies": [ 
    "qt5", 
    "qt-advanced-docking-system", 
    "qtkeychain" 
  ]
}
```

The `"qt*"` pattern matches all port names in `vcpkg.json`. But there is a problem!
The ports `qt-advanced-docking-system` and `qtkeychain` are not part of the official Qt Framework libraries, 
because of this vcpkg won't be able to find the ports in the custom registry.

The obvious solution is to make sure that these packages come from the default registry instead,
we can accomplish that by adding an entry for the default registry:

`vcpkg-configuration.json`
```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/Microsoft/vcpkg",
      "baseline": "e79c0d2b5d72eb3063cf32a1f7de1a9cf19930f3",
      "packages": ["*", "qt-advanced-docking-system", "qtkeychain"]
    },
    {
      "kind": "git",
      "repository": "https://github.com/custom-qt/custom-qt-registry",
      "baseline": "adfc4de488094a384ca2c202b923ccc097956e0c",
      "packages": ["qt*"]
    }
  ]
}
```

Because exact matches are preferred over pattern matches, this configuration will make
`qt-advanced-docking-system` and `qtkeycahin` resolve to the overriden default registry.

### Versioning Support

Versioning with custom registries works exactly as it does in the built-in
registry. You can read more about that in the [versioning documentation].

[versioning documentation]: versioning.md