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

The `"baseline"` field must be a string. For git registries and for the 
built-in registry, it should be a 40-character commit ID.
For filesystem registries, it can be any string that the registry defines.

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

The way package name resolution works in vcpkg is fairly distinct from many
package managers. It is very carefully designed to _never_ implicitly choose
the registry that a package is fetched from. Just from
`vcpkg-configuration.json`, one can tell exactly from which registry a
package definition will be fetched from.

The name resolution algorithm is as follows:

- If there is a package registry that claims the package name,
  use that registry; otherwise
- If there is a default registry defined, use that registry; otherwise
- If the default registry is set to `null`, error out; otherwise
- use the built-in registry.

### Versioning Support

Versioning with custom registries works exactly as it does in the built-in
registry. You can read more about that in the [versioning documentation].

[versioning documentation]: versioning.md