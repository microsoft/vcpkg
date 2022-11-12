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
    - [Configuration: `"default-registry"`](#configuration-default-registry)
    - [Configuration: `"registries"`](#configuration-registries)
    - [Configuration: `"overlay-ports"`](#configuration-overlay-ports)
    - [Configuration: `"overlay-triplets"`](#configuration-overlay-triplets)
    - [Example Configuration File](#example-configuration-file)
  - [Package Name Resolution](#package-name-resolution)
    - [Overlays Resolution](#overlays-resolution)
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

### Configuration: `"overlay-ports"`

An array of port overlay paths.

Each path in the array must point to etiher:
* a particular port directory (a directory containing `vcpkg.json` and `portfile.cmake`), or
* a directory containing port directories.
Relative paths are resolved relative to the `vcpkg-configuration.json` file. Absolute paths can be used but are discouraged.

### Configuration: `"overlay-triplets"`

An array of triplet overlay paths.

Each path in the array must point to a directory of triplet files ([see triplets documentation](triplets.md)).
Relative paths are resolved relative to the `vcpkg-configuration.json` file. Absolute paths can be used but are discouraged.

### Example Configuration File

Let's assume that you have mirrored <https://github.com/microsoft/vcpkg> at
<https://git.example.com/vcpkg>: this will be your default registry.
Additionally, you want to use North Wind Trader's registry for their
beison and beicode libraries, as well as configure overlay ports and 
overlay triplets from your custom directories. The following
`vcpkg-configuration.json` will work:

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
  ],
  "overlay-ports": [ "./team-ports",
                     "c:/project/my-ports/fmt",
                     "./custom-ports"
   ],
  "overlay-triplets": [ "./my-triplets" ]
}
```

## Package Name Resolution

The way package name resolution works in vcpkg is fairly distinct from many
package managers. It is very carefully designed to _never_ implicitly choose
the registry that a package is fetched from. Just from
`vcpkg-configuration.json`, one can tell exactly from which registry a
package definition will be fetched from.

The name resolution algorithm is as follows:

- If the name matches an [overlay](#overlays-resolution), use that overlay; otherwise
- If there is a package registry that claims the package name,
  use that registry; otherwise
- If there is a default registry defined, use that registry; otherwise
- If the default registry is set to `null`, error out; otherwise
- use the built-in registry.

### Overlays Resolution

Overlay ports and triplets are evaluated in this order:

1. Overlays from the [command line](../commands/common-options.md)
2. Overlays from `vcpkg-configuration.json`
3. Overlays from the `VCPKG_OVERLAY_[PORTS|TRIPLETS]` [environment](config-environment.md) variable.

Additionaly, each method has its own evaluation order:

* Overlays from the command line are evaluated from left-to-right in the order each argument is passed, with each `--overlay-[ports|triplets]` argument adding a new overlay location.
* Overlays from `vcpkg-configuration.json` are evaluated in the order of the `"overlay-[ports|triplets]"` array.
* Overlays set by `VCPKG_OVERLAY_[PORTS|TRIPLETS]` are evaluated from left-to-right. Overlay locations are separated by an OS-specific path separator (`;` on Windows and `:` on non-Windows).

### Versioning Support

Versioning with custom registries works exactly as it does in the built-in
registry. You can read more about that in the [versioning documentation].

[versioning documentation]: versioning.md
